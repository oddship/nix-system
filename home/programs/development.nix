{ config, lib, pkgs, ... }:
{
  # Neovim configuration
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;
    
    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set wrap
      set linebreak
      
      " Search settings
      set ignorecase
      set smartcase
      set hlsearch
      set incsearch
      
      " UI settings
      set termguicolors
      set signcolumn=yes
      set updatetime=100
      set timeoutlen=300
      
      " Persistence
      set undofile
      set undodir=~/.vim/undodir
      set swapfile
      set dir=~/.vim/swap
      
      " Better navigation
      set scrolloff=8
      set sidescrolloff=8
      
      " Split settings
      set splitbelow
      set splitright
      
      " Key mappings
      let mapleader = " "
      
      " Better window navigation
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l
      
      " Resize with arrows
      nnoremap <C-Up> :resize -2<CR>
      nnoremap <C-Down> :resize +2<CR>
      nnoremap <C-Left> :vertical resize -2<CR>
      nnoremap <C-Right> :vertical resize +2<CR>
      
      " Move text up and down
      vnoremap J :m '>+1<CR>gv=gv
      vnoremap K :m '<-2<CR>gv=gv
      
      " Better indenting
      vnoremap < <gv
      vnoremap > >gv
    '';
    
    plugins = with pkgs.vimPlugins; [
      # Theme
      tokyonight-nvim
      
      # Essential plugins
      plenary-nvim
      nvim-web-devicons
      
      # File explorer
      nvim-tree-lua
      
      # Fuzzy finder
      telescope-nvim
      telescope-fzf-native-nvim
      
      # Syntax highlighting
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      
      # LSP
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      
      # UI enhancements
      lualine-nvim
      bufferline-nvim
      indent-blankline-nvim
      gitsigns-nvim
      
      # Utilities
      comment-nvim
      nvim-autopairs
      which-key-nvim
      vim-surround
      vim-repeat
    ];
  };

  # VS Code configuration
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    
    extensions = with pkgs.vscode-extensions; [
      # Theme
      enkia.tokyo-night
      
      # Language support
      ms-python.python
      golang.go
      rust-lang.rust-analyzer
      hashicorp.terraform
      ms-azuretools.vscode-docker
      redhat.vscode-yaml
      tamasfe.even-better-toml
      
      # Nix
      jnoortheen.nix-ide
      mkhl.direnv
      
      # Git
      eamodio.gitlens
      mhutchie.git-graph
      
      # Utilities
      esbenp.prettier-vscode
      dbaeumer.vscode-eslint
      usernamehw.errorlens
      streetsidesoftware.code-spell-checker
      wayou.vscode-todo-highlight
      gruntfuggly.todo-tree
      
      # Remote development
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-containers
    ];
    
    userSettings = {
      "editor.fontFamily" = "'JetBrains Mono', 'monospace'";
      "editor.fontSize" = 14;
      "editor.fontLigatures" = true;
      "editor.formatOnSave" = true;
      "editor.minimap.enabled" = false;
      "editor.rulers" = [ 80 120 ];
      "editor.renderWhitespace" = "trailing";
      "editor.suggestSelection" = "first";
      "editor.bracketPairColorization.enabled" = true;
      "editor.inlineSuggest.enabled" = true;
      
      "workbench.colorTheme" = "Tokyo Night";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.startupEditor" = "none";
      
      "terminal.integrated.fontFamily" = "'JetBrains Mono'";
      "terminal.integrated.fontSize" = 14;
      
      "git.autofetch" = true;
      "git.confirmSync" = false;
      "git.enableSmartCommit" = true;
      
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;
      
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
    };
  };

  # Node.js development
  programs.fnm = {
    enable = true;
    enableZshIntegration = true;
  };

  # Additional development packages
  home.packages = with pkgs; [
    # Language servers
    nil  # Nix LSP
    gopls  # Go LSP
    rust-analyzer  # Rust LSP
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    lua-language-server
    python3Packages.python-lsp-server
    
    # Formatters
    nixfmt-rfc-style
    gofumpt
    rustfmt
    prettier
    black
    stylua
    
    # Linters
    golangci-lint
    clippy
    eslint_d
    ruff
    
    # Development tools
    httpie
    jq
    yq
    fx
    glow
    tokei  # Code statistics
    hyperfine  # Benchmarking
    
    # Database tools
    pgcli
    mycli
    litecli
    redis
    
    # Container tools
    lazydocker
    dive
    
    # API development
    postman
    insomnia
    
    # Documentation
    mdbook
    pandoc
  ];
}