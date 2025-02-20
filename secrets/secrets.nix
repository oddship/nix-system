let
  rhnvrm_ed25519 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsBh6mM1T0HyG8Gp4doFEo8izvF8snx4wJXmkyzZCBw hello@rohanverma.net";
  users = [ rhnvrm_ed25519 ];

  thinkpadx1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFaS218MkohpmXFgAPcaJNJmQ/GhYwduDdilFdztVivQ";
  systems = [ thinkpadx1 ];
in
{
  "login_pass_thinkpad.age".publicKeys = [ rhnvrm_ed25519 thinkpadx1 ];
}