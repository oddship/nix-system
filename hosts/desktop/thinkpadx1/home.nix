{
  inputs,
  pkgs,
  gitConfigExtra ? "",
  ...
}:
let
  wallpaper = pkgs.fetchurl {
    url = "https://w.wallhaven.cc/full/2y/wallhaven-2yrwzy.jpg";
    hash = "sha256-OJBIdULF8iElf2GNl2Nmedh5msVSSWbid2RtYM5Cjog=";
  };

  # TODO: syncthingtray does not work on first boot correctly
  autostartPrograms = [
    pkgs.syncthingtray-minimal
    pkgs.ktailctl
  ];
in
{
  imports = [
    ../../../home/profiles/desktop.nix
  ];

  home.username = "rhnvrm";
  home.homeDirectory = "/home/rhnvrm";

  home.stateVersion = "24.11";
  # Host-specific packages (additional to desktop profile)
  home.packages = with pkgs; [
    # Only truly host-specific packages here
    # Common packages moved to desktop profile
    websocat
  ];

  # MIME apps configuration in desktop profile

  # GNOME dconf settings moved to home/profiles/desktop.nix to avoid duplication
  # Only host-specific overrides should be here

  programs.home-manager.enable = true;

  # Program configurations moved to home/profiles/desktop.nix to avoid duplication
  # Only host-specific program overrides should be here

  # Host-specific git config (if needed)
  programs.git.includes = [
    {
      path = gitConfigExtra; # TODO: need to figure out a better way to do this
    }
  ];

  # Autostart XDG for gnome (ref: https://github.com/nix-community/home-manager/issues/3447)
  home.file = builtins.listToAttrs (
    map (pkg: {
      name = ".config/autostart/" + pkg.pname + ".desktop";
      value =
        if pkg ? desktopItem then
          {
            # Application has a desktopItem entry.
            # Assume that it was made with makeDesktopEntry, which exposes a
            # text attribute with the contents of the .desktop file
            text = pkg.desktopItem.text;
          }
        # For ktailctl, /share/applications/org.fkoehler.KTailctl.desktop is the name so add a manual
        # entry for it
        else if pkg.pname == "ktailctl" then
          {
            source = (pkg + "/share/applications/org.fkoehler.KTailctl.desktop");
          }
        else
          {
            # Application does *not* have a desktopItem entry. Try to find a
            # matching .desktop name in /share/applications
            source = (pkg + "/share/applications/" + pkg.pname + ".desktop");
          };
    }) autostartPrograms
  );
}
