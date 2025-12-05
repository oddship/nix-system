{ lib, pkgs, ... }:
{
  # Modern systemd-boot setup
  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };

  # Use CachyOS LTS kernel (6.12.x) with EEVDF-BORE scheduler for better desktop responsiveness
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_cachyos-lts;

  # Enable kernel modules for common hardware
  boot.initrd.availableKernelModules = lib.mkDefault [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

  # Kernel parameters for better desktop experience
  boot.kernelParams = lib.mkDefault [
    "quiet"
    "splash"
  ];

  # Enable Plymouth for boot splash (optional)
  boot.plymouth.enable = lib.mkDefault false;

  # Clean /tmp on boot
  boot.tmp.cleanOnBoot = lib.mkDefault true;
}
