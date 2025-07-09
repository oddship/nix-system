{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hardware.laptop;
in
{
  options.hardware.laptop = {
    enable = lib.mkEnableOption "laptop-specific hardware configuration";
  };

  config = lib.mkIf cfg.enable {
    # Empty - no laptop-specific configuration in original
  };
}
