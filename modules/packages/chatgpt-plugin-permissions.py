"""Patch the pinned app's Linux plugin copy step without repacking native files.

Fail closed when upstream changes the anchor. Only newly copied plugin staging
trees become writable; symlinks, the Nix store, and browser profiles are untouched.
"""

import hashlib
import json
from pathlib import Path
import struct
import sys


COPY = b'await y.default.cp(e,t,{recursive:!0,verbatimSymlinks:!0});return'
FUNCTION = b'async function Cte(e,t){'
HELPER = b'''async function nixMakePluginCopyWritable(e){
let t=await y.default.lstat(e);if(t.isSymbolicLink())return;
await y.default.chmod(e,t.mode|(t.isDirectory()?448:384));
if(t.isDirectory())for(let t of await y.default.readdir(e))
await nixMakePluginCopyWritable((0,p.join)(e,t))}
'''


def entries(tree, prefix=''):
    for name, entry in tree['files'].items():
        path = f'{prefix}/{name}' if prefix else name
        if 'files' in entry:
            yield from entries(entry, path)
        else:
            yield path, entry


def patch(archive):
    data = archive.read_bytes()
    size_payload, header_size, header_payload, json_size = struct.unpack_from('<4I', data)
    if size_payload != 4 or header_size != header_payload + 4:
        raise RuntimeError('Unsupported ASAR header layout')
    header = json.loads(data[16:16 + json_size])
    body = data[8 + header_size:]
    files = list(entries(header))
    matches = []
    for name, entry in files:
        if name.startswith('.vite/build/main-') and name.endswith('.js') and 'offset' in entry:
            offset = int(entry['offset'])
            source = body[offset:offset + entry['size']]
            if COPY in source and FUNCTION in source:
                matches.append((name, entry, source))
    if len(matches) != 1:
        raise RuntimeError(f'Expected one pinned plugin copy implementation, found {len(matches)}')
    name, target, source = matches[0]
    if source.count(COPY) != 1 or source.count(FUNCTION) != 1:
        raise RuntimeError('Plugin copy anchors are ambiguous')
    patched = source.replace(FUNCTION, HELPER + FUNCTION).replace(
        COPY, COPY.replace(b';return', b';await nixMakePluginCopyWritable(t);return')
    )
    offset, old_size = int(target['offset']), target['size']
    delta = len(patched) - old_size
    body = body[:offset] + patched + body[offset + old_size:]
    for _, entry in files:
        if 'offset' in entry and int(entry['offset']) > offset:
            entry['offset'] = str(int(entry['offset']) + delta)
    target['size'] = len(patched)
    if 'integrity' in target:
        integrity = target['integrity']
        if integrity['algorithm'] != 'SHA256':
            raise RuntimeError('Unsupported ASAR integrity algorithm')
        block_size = integrity['blockSize']
        integrity['hash'] = hashlib.sha256(patched).hexdigest()
        integrity['blocks'] = [
            hashlib.sha256(patched[i:i + block_size]).hexdigest()
            for i in range(0, len(patched), block_size)
        ]
    encoded = json.dumps(header, ensure_ascii=False, separators=(',', ':')).encode()
    payload = struct.pack('<I', len(encoded)) + encoded
    payload += b'\0' * (-len(payload) % 4)
    packed_header = struct.pack('<I', len(payload)) + payload
    output = struct.pack('<II', 4, len(packed_header)) + packed_header + body
    temporary = archive.with_name(archive.name + '.nix-patched')
    with temporary.open('xb') as handle:
        handle.write(output)
    temporary.chmod(archive.stat().st_mode & 0o777)
    temporary.replace(archive)
    print(f'Patched {name}: writable Linux plugin staging copies; unpacked files unchanged')


if __name__ == '__main__':
    patch(Path(sys.argv[1]))
