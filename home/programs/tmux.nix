{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Tmux Configuration
  # =================
  #
  # Key Bindings:
  # - Prefix: Ctrl+a (instead of default Ctrl+b)
  # - Split panes: | (horizontal), - (vertical)
  # - Navigate panes: Alt+arrows (no prefix needed)
  # - Resize panes: Ctrl+arrows (with prefix)
  # - Switch windows: Shift+arrows (no prefix needed)
  # - Copy mode: v (select), y (copy), r (rectangle mode)
  # - Reload config: prefix + r
  #
  # Available aliases (from shell.nix):
  # - tm = tmux
  # - tma = tmux attach-session -t
  # - tmn = tmux new-session -s
  # - tml = tmux list-sessions
  # - tmk = tmux kill-session -t
  # - tms = tmux-session (interactive session manager)
  # - tmd = tmux-session --dev (create dev session)
  #
  # Functions (from shell.nix):
  # - tmux-dev: Create development session for current directory
  # - tmux-attach: Attach to session with fzf selection
  #
  # Session Manager Script:
  # - Run 'tmux-session.sh' or use alias 'tms' for interactive menu
  # - Run 'tmux-session.sh -d' or use alias 'tmd' for dev session

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 100000;
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;

    plugins = with pkgs.tmuxPlugins; [
      sensible # Sensible defaults
      yank # Copy to system clipboard
      resurrect # Save/restore sessions
      continuum # Auto-save sessions
      fzf-tmux-url # Open URLs with fzf
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-battery false
          set -g @dracula-show-network false
          set -g @dracula-show-weather false
          set -g @dracula-show-powerline true
          set -g @dracula-refresh-rate 10
        '';
      }
    ];

    extraConfig = ''
      # Better prefix key
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      # Split panes using | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # Switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Resize panes using Ctrl-arrow with prefix
      bind -r C-Left resize-pane -L 5
      bind -r C-Right resize-pane -R 5
      bind -r C-Up resize-pane -U 5
      bind -r C-Down resize-pane -D 5

      # Switch windows using Shift-arrow without prefix
      bind -n S-Left previous-window
      bind -n S-Right next-window

      # Create new window with current path
      bind c new-window -c "#{pane_current_path}"

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # Copy mode improvements
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
      bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

      # Session management
      bind-key S choose-session
      bind-key s switch-client -l

      # Window management
      bind-key w list-windows
      bind-key W choose-window

      # Pane management
      bind-key x confirm-before -p "kill-pane #P? (y/n)" kill-pane
      bind-key X confirm-before -p "kill-window #W? (y/n)" kill-window

      # Status bar customization
      set -g status-position bottom
      set -g status-justify left
      set -g status-style 'bg=colour234 fg=colour137 dim'
      set -g status-left ""
      set -g status-right "#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S "
      set -g status-right-length 50
      set -g status-left-length 20

      # Window status
      setw -g window-status-current-style 'fg=colour1 bg=colour19 bold'
      setw -g window-status-current-format " #I#[fg=colour249]:#[fg=colour255]#W#[fg=colour249]#F "
      setw -g window-status-style 'fg=colour9 bg=colour18'
      setw -g window-status-format " #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F "

      # Pane borders
      set -g pane-border-style 'fg=colour238 bg=colour235'
      set -g pane-active-border-style 'bg=colour236 fg=colour51'

      # Message styling
      set -g message-style 'fg=colour232 bg=colour166 bold'

      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off

      # Enable focus events for vim
      set -g focus-events on

      # Don't rename windows automatically
      set-option -g allow-rename off

      # Increase repeat time for repeatable commands
      set -g repeat-time 1000

      # Start windows and panes at 1
      set -g base-index 1
      setw -g pane-base-index 1

      # Renumber windows when one is closed
      set -g renumber-windows on

      # Enable true color support
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'

      # Ghostty terminal compatibility
      set -g default-terminal "screen-256color"
      if-shell 'test "$TERM_PROGRAM" = "ghostty"' 'set -g default-terminal "xterm-256color"'
    '';
  };
}
