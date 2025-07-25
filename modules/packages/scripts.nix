{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.packages.scripts;

  # Custom scripts package
  my-scripts = pkgs.stdenv.mkDerivation {
    name = "my-scripts";
    src = ../../scripts;

    buildInputs = with pkgs; [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin

      # Copy all shell scripts to bin and make them executable
      for script in $src/*.sh; do
        if [ -f "$script" ]; then
          script_name=$(basename "$script" .sh)
          cp "$script" "$out/bin/$script_name"
          chmod +x "$out/bin/$script_name"
          
          # Wrap scripts to ensure dependencies are available
          wrapProgram "$out/bin/$script_name" \
            --prefix PATH : ${
              lib.makeBinPath (
                with pkgs;
                [
                  bash
                  coreutils
                  gawk
                  lsof
                  fzf
                  procps
                  sudo
                  util-linux
                  # Clipboard utilities
                  xclip
                  xsel
                  wl-clipboard
                  # Markdown rendering
                  pandoc
                ]
              )
            }
        fi
      done
    '';

    meta = with lib; {
      description = "Personal shell scripts collection";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };
in
{
  options.packages.scripts = {
    enable = lib.mkEnableOption "personal shell scripts";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ my-scripts ];
  };
}
