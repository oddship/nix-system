{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.packages.libreoffice;
in
{
  options.packages.libreoffice = {
    enable = lib.mkEnableOption "LibreOffice suite";
    
    version = lib.mkOption {
      type = lib.types.enum [ "fresh" "still" ];
      default = "fresh";
      description = "LibreOffice version to install (fresh = latest, still = stable)";
    };
    
    withLanguagePacks = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include additional language packs";
    };
    
    withSpellcheck = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include spell checking dictionaries";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Main LibreOffice package
      (if cfg.version == "fresh" then libreoffice-fresh else libreoffice-still)
      
      # Language packs and spell checkers
    ] ++ lib.optionals cfg.withLanguagePacks [
      # Additional language support
      hunspell
    ] ++ lib.optionals cfg.withSpellcheck [
      # Spell checking dictionaries
      hunspellDicts.en_US
      hunspellDicts.en_GB-ise
    ];
  };
}