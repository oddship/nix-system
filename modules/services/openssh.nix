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

    settings = {
      PasswordAuthentication = lib.mkDefault false;
      KbdInteractiveAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "prohibit-password";
      X11Forwarding = lib.mkDefault false;
      
      # Hardening
      StrictModes = lib.mkDefault true;
      IgnoreRhosts = lib.mkDefault true;
      HostbasedAuthentication = lib.mkDefault false;
      PermitEmptyPasswords = lib.mkDefault false;
      PermitUserEnvironment = lib.mkDefault false;
      
      # Performance
      UseDNS = lib.mkDefault false;
      ClientAliveInterval = lib.mkDefault 60;
      ClientAliveCountMax = lib.mkDefault 3;
      
      # Modern ciphers only
      Ciphers = lib.mkDefault [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
      ];
      
      KexAlgorithms = lib.mkDefault [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
      ];
      
      MACs = lib.mkDefault [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
      ];
    };
  };

  # Fail2ban for SSH protection
  services.fail2ban = {
    enable = lib.mkDefault true;
    maxretry = lib.mkDefault 5;
    ignoreIP = lib.mkDefault [
      "127.0.0.0/8"
      "::1"
    ];
  };
}