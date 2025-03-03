{ config, pkgs, ... }:
{
  services.flatpak.enable = true;
  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
  ];
  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly"; # default value
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
    "com.vivaldi.Vivaldi"
    "com.spotify.Client"
  ];
}
