{ config, lib, pkgs, ... }:
{
  # Kitty terminal
  programs.kitty = {
    enable = true;
    theme = "Tokyo Night";
    font = {
      name = "JetBrains Mono";
      size = 12;
    };
    settings = {
      enable_audio_bell = false;
      window_padding_width = 10;
      background_opacity = "0.95";
      hide_window_decorations = false;
      confirm_os_window_close = 0;
      
      # Scrollback
      scrollback_lines = 10000;
      
      # Tabs
      tab_bar_edge = "top";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;
    };
    keybindings = {
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+n" = "new_window";
      "ctrl+shift+enter" = "new_window_with_cwd";
    };
  };

  # Ghostty terminal
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "tokyo-night";
      font-family = "JetBrains Mono";
      font-size = 12;
      
      # Window
      window-decoration = true;
      window-padding-x = 10;
      window-padding-y = 10;
      
      # Cursor
      cursor-style = "block";
      cursor-style-blink = true;
      
      # Background
      background-opacity = 0.95;
      background-blur-radius = 20;
      
      # Scrollback
      scrollback-limit = 10000;
      
      # Copy on select
      copy-on-select = true;
      
      # Bell
      audible-bell = false;
      visual-bell = true;
      
      # Performance
      gtk-single-instance = true;
    };
  };

  # Tmux for terminal multiplexing
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      pain-control
      sessionist
      tmux-thumbs
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];
    
    extraConfig = ''
      # Set prefix to Ctrl-a
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix
      
      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1
      
      # Renumber windows on close
      set -g renumber-windows on
      
      # Split panes with | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %
      
      # Easy pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      
      # Easy pane resizing
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
      
      # Easy window navigation
      bind -r C-h previous-window
      bind -r C-l next-window
      
      # Status bar
      set -g status-position bottom
      set -g status-style 'bg=#1a1b26 fg=#a9b1d6'
      set -g status-left '#[fg=#7aa2f7,bold] #S '
      set -g status-right '#[fg=#7aa2f7] %Y-%m-%d %H:%M '
      set -g status-left-length 30
      
      # Window status
      setw -g window-status-style 'fg=#787c99'
      setw -g window-status-format ' #I:#W '
      setw -g window-status-current-style 'fg=#7aa2f7,bold,bg=#3b4261'
      setw -g window-status-current-format ' #I:#W '
      
      # Pane borders
      set -g pane-border-style 'fg=#3b4261'
      set -g pane-active-border-style 'fg=#7aa2f7'
      
      # Message style
      set -g message-style 'fg=#7aa2f7 bg=#3b4261 bold'
    '';
  };

  # Additional terminal utilities
  home.packages = with pkgs; [
    # Terminal emulators
    wezterm
    alacritty
    
    # Terminal utilities
    ncurses
    tmate
    asciinema
    termshark
    glow  # Markdown renderer for terminal
  ];
}