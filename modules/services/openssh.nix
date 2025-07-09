{ lib, ... }:
{
  services.openssh = {
    enable = lib.mkDefault true;

    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
}
