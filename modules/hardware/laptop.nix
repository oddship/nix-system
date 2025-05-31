{ config, lib, pkgs, ... }:
let
  cfg = config.hardware.laptop;
in
{
  options.hardware.laptop = {
    enable = lib.mkEnableOption "laptop-specific hardware configuration";
    
    powersave = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable power saving features";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Power management
    powerManagement = {
      enable = true;
      powertop.enable = true;
    };
    
    # Thermal management
    services.thermald.enable = true;
    
    # CPU frequency scaling
    services.auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
    
    # TLP for better battery life
    services.tlp = lib.mkIf cfg.powersave.enable {
      enable = true;
      settings = {
        # CPU
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        
        # Turbo boost
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        
        # Platform profiles
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        
        # PCIe power management
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "auto";
        
        # USB autosuspend
        USB_AUTOSUSPEND = 1;
        USB_EXCLUDE_PHONE = 1;
        
        # WiFi power saving
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
        
        # Sound power saving
        SOUND_POWER_SAVE_ON_AC = 0;
        SOUND_POWER_SAVE_ON_BAT = 1;
        
        # Disk devices
        DISK_DEVICES = "nvme0n1 sda";
        DISK_APM_LEVEL_ON_AC = "254 254";
        DISK_APM_LEVEL_ON_BAT = "128 128";
        
        # Battery care
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    # Laptop-specific kernel modules
    boot.kernelModules = [ 
      "acpi_call" 
      "coretemp"
    ];
    
    # Enable firmware updates
    services.fwupd.enable = true;
    
    # Touchpad and input
    services.libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        clickMethod = "clickfinger";
        disableWhileTyping = true;
      };
    };
    
    # Backlight control
    programs.light.enable = true;
    
    # Enable trim for SSDs
    services.fstrim.enable = true;
    
    # Laptop mode tools
    services.logind = {
      lidSwitch = "suspend";
      lidSwitchExternalPower = "suspend";
      extraConfig = ''
        HandlePowerKey=suspend
        IdleAction=suspend
        IdleActionSec=15min
      '';
    };
    
    # Enable bluetooth
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = false;
      settings = {
        General = {
          FastConnectable = true;
          Experimental = true;
        };
      };
    };
    
    # Enable sound
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    
    # Brightness keys
    services.actkbd = {
      enable = true;
      bindings = [
        { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
        { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
      ];
    };
  };
}