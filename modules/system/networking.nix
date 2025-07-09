{ lib, ... }:
{
  # NetworkManager for easy network management
  networking.networkmanager.enable = lib.mkDefault true;

  # Modern firewall setup
  networking.firewall = {
    enable = lib.mkDefault true;
    logRefusedConnections = lib.mkDefault true;
  };

  # Use nftables for better performance
  networking.nftables.enable = lib.mkDefault true;

  # Enable mDNS for local network discovery
  services.avahi = {
    enable = lib.mkDefault true;
    nssmdns4 = lib.mkDefault true;
    openFirewall = lib.mkDefault true;
  };

  # Enable resolved for better DNS management
  services.resolved = {
    enable = lib.mkDefault true;
    dnssec = lib.mkDefault "true";
    domains = [ "~." ];
    fallbackDns = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };

  # Network optimization
  boot.kernel.sysctl = {
    # TCP Fast Open for both incoming and outgoing connections
    "net.ipv4.tcp_fastopen" = lib.mkDefault 3;

    # Increase TCP congestion control algorithm
    "net.ipv4.tcp_congestion" = lib.mkDefault "bbr";

    # Increase max connections
    "net.core.somaxconn" = lib.mkDefault 1024;
  };
}
