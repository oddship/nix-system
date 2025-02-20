
## Initial setup

Boot into a live NixOS USB and enable networking and ssh on the target.

```sh
nix run github:nix-community/nixos-anywhere -- --build-on-remote --flake .#oddship-thinkpad-x1 --target-host nixos@<IP_ADDRESS>
```

```
mkpasswd -m bcrypt
```