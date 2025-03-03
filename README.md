
## Initial setup

Boot into a live NixOS USB and enable networking and ssh on the target.

```sh
nix run github:nix-community/nixos-anywhere -- --build-on-remote --flake .#oddship-thinkpad-x1 --target-host nixos@<IP_ADDRESS>
```

For generating login pass:

```
mkpasswd -m bcrypt
```

## TODO

- moving .ssh folder. (agenix it?)
- maybe lanzboote and disk encryption pass (in agenix ?)

## Post-installation


Run the following commands after installation to update firmware manually:

```sh
fwupdmgr get-devices
fwupdmgr refresh
fwupdmgr get-updates
fwupdmgr update
```
