let
  rhnvrm_ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsBh6mM1T0HyG8Gp4doFEo8izvF8snx4wJXmkyzZCBw hello@rohanverma.net";
  users = [ rhnvrm_ed25519 ];

  thinkpadx1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDx7uPdD2Fc/3j/2cx1VPYxoN9lL3QR4KTPzVhsGTaM8";
  ux303 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+P0DWqkyUAV26Gh2vBP7LnUV/VhehvMXsnBU0QLAi2";
  oddship_web = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIENlny0k4YL4ZoLY2A8Z82n4PyK2pR0XtiM7S9KgPOGV"; # hetzner vps
  systems = [
    oddship_web
    thinkpadx1
    ux303
  ];
in
{
  "login_pass_thinkpad.age".publicKeys = [
    rhnvrm_ed25519
    thinkpadx1
  ];
  "git-config-extra.age".publicKeys = [
    rhnvrm_ed25519
    thinkpadx1
  ];
  "wifi_pass_ux303.age".publicKeys = [
    rhnvrm_ed25519
    ux303
  ];
  "hetzner-api-token.age".publicKeys = [
    rhnvrm_ed25519
    thinkpadx1
  ];
  "cloudflare-api-token.age".publicKeys = [
    rhnvrm_ed25519
    thinkpadx1
    oddship_web
  ];
}
