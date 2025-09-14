{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Neovim Configuration
  # ===================
  #
  # Key Features:
  # - SpaceVim-style keybindings with which-key integration
  # - Full LSP support with auto-completion
  # - GitHub Copilot integration
  # - Treesitter syntax highlighting
  # - File management with Telescope and nvim-tree
  # - Git integration with gitsigns and fugitive
  # - Modern UI with lualine and bufferline
  # - Development essentials (autopairs, comments, snippets)
  # - Enhanced navigation with easymotion and sneak
  # - Better start screen with startify
  #
  # SpaceVim-style Key Bindings (Leader: Space):
  # - <leader>ff: Find files
  # - <leader>fg: Live grep
  # - <leader>fb: Buffer list
  # - <leader>fe: File explorer
  # - <leader>ss: Search text
  # - <leader>bb: Switch buffer
  # - <leader>wh/j/k/l: Window navigation
  # - <leader>gs: Git status
  # - <leader>ld: LSP definitions
  # - <leader>la: LSP code actions
  # - <leader>tt: Toggle terminal
  # - <leader>qq: Quit
  # - jk/kj: Exit insert mode
  # - <leader><leader>s: EasyMotion search
  # - s/S: Sneak forward/backward
  # - H/L: Line start/end
  # - J/K: Move 5 lines down/up

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      # Bootstrap plugin manager
      plenary-nvim # Required by many plugins
    ];

    extraPackages = with pkgs; [
      # Language servers
      pyright           # Python LSP
      nil               # Nix LSP
      nodePackages.typescript-language-server  # TypeScript/JavaScript
      gopls             # Go LSP
      rust-analyzer     # Rust LSP
      nodePackages.bash-language-server       # Bash LSP
      nodePackages.vscode-langservers-extracted  # JSON/HTML/CSS/ESLint
      yaml-language-server  # YAML LSP
      
      # Formatters and tools
      nodePackages.prettier
    ];

    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set softtabstop=2
      set autoindent
      set smartindent
      set wrap
      set ignorecase
      set smartcase
      set incsearch
      set hlsearch
      set hidden
      set backup
      set writebackup
      set undofile
      set mouse=a
      set clipboard=unnamedplus
      set updatetime=300
      set signcolumn=yes
      set cursorline
      set scrolloff=8
      set sidescrolloff=8
      set splitbelow
      set splitright
      set termguicolors

      " Leader key
      let mapleader = " "

      " Clear search highlighting
      nnoremap <Esc> :nohlsearch<CR>

      " Better window navigation
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      " Better buffer navigation
      nnoremap <Tab> :bnext<CR>
      nnoremap <S-Tab> :bprevious<CR>

      " Quick save and quit
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>
      nnoremap <leader>x :x<CR>

      " GitHub Copilot settings
      let g:copilot_no_tab_map = v:true
      let g:copilot_assume_mapped = v:true
      let g:copilot_tab_fallback = ""

      " Copilot accept with Ctrl+J
      imap <C-J> <Plug>(copilot-accept-word)
      imap <C-L> <Plug>(copilot-accept-line)

      " Color scheme (set in Lua config after plugin loads)
    '';

    extraLuaConfig = ''
      -- Bootstrap lazy.nvim
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable",
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)

      -- Configure lazy.nvim
      require("lazy").setup({
        -- Theme
        {
          "catppuccin/nvim",
          name = "catppuccin",
          lazy = false,
          priority = 1000,
          config = function()
            require("catppuccin").setup({
              flavour = "mocha", -- Set to mocha to match Ghostty
            })
            vim.cmd.colorscheme("catppuccin-mocha")
          end,
        },
        
        -- LSP Configuration
        {
          "neovim/nvim-lspconfig",
          dependencies = {
            "hrsh7th/cmp-nvim-lsp",
          },
          config = function()
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            
            local servers = {
              'nil_ls', 'pyright', 'ts_ls', 'gopls', 'rust_analyzer', 
              'bashls', 'jsonls', 'yamlls'
            }
            
            for _, server in ipairs(servers) do
              lspconfig[server].setup {
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                  local bufopts = { noremap=true, silent=true, buffer=bufnr }
                  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
                  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
                  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
                  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
                  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
                  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
                  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
                  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
                end,
              }
            end
          end,
        },
        
        -- Completion
        {
          "hrsh7th/nvim-cmp",
          dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
          },
          config = function()
            local cmp = require('cmp')
            local luasnip = require('luasnip')
            
            require('luasnip.loaders.from_vscode').lazy_load()
            
            cmp.setup({
              snippet = {
                expand = function(args)
                  luasnip.lsp_expand(args.body)
                end,
              },
              mapping = cmp.mapping.preset.insert({
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ['<Tab>'] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                  else
                    fallback()
                  end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_prev_item()
                  elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                  else
                    fallback()
                  end
                end, { 'i', 's' }),
              }),
              sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
              }, {
                { name = 'buffer' },
              })
            })
          end,
        },
        
        -- GitHub Copilot
        { "github/copilot.vim" },
        
        -- Treesitter
        {
          "nvim-treesitter/nvim-treesitter",
          build = ":TSUpdate",
          config = function()
            require('nvim-treesitter.configs').setup {
              ensure_installed = { "nix", "lua", "python", "javascript", "typescript", "json", "yaml", "toml", "markdown", "bash", "go", "rust", "html", "css" },
              auto_install = true,
              highlight = { enable = true },
              indent = { enable = true },
            }
          end,
        },
        
        -- Telescope
        {
          "nvim-telescope/telescope.nvim",
          dependencies = { 
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
          },
          config = function()
            local telescope = require('telescope')
            telescope.setup({
              defaults = {
                mappings = {
                  i = {
                    ["<C-j>"] = require('telescope.actions').move_selection_next,
                    ["<C-k>"] = require('telescope.actions').move_selection_previous,
                  },
                },
              },
            })
            telescope.load_extension('fzf')
          end,
        },
        
        -- Modern File Explorer (VS Code-like)
        {
          "nvim-neo-tree/neo-tree.nvim",
          branch = "v3.x",
          dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
          },
          config = function()
            require('neo-tree').setup({
              close_if_last_window = true,
              popup_border_style = "rounded",
              enable_git_status = true,
              enable_diagnostics = true,
              filesystem = {
                filtered_items = {
                  visible = true,
                  hide_dotfiles = false,
                  hide_gitignored = false,
                },
                follow_current_file = {
                  enabled = true,
                  leave_dirs_open = true,
                },
                use_libuv_file_watcher = true,
              },
              window = {
                position = "left",
                width = 30,
                mapping_options = {
                  noremap = true,
                  nowait = true,
                },
              },
              default_component_configs = {
                git_status = {
                  symbols = {
                    added = "✚",
                    modified = "✱",
                    deleted = "✖",
                    renamed = "󰁕",
                    untracked = "★",
                    ignored = "◌",
                    unstaged = "✗",
                    staged = "✓",
                    conflict = "",
                  },
                },
              },
            })
          end,
        },
        
        
        -- Better Unified Diff Viewer
        {
          "echasnovski/mini.diff",
          config = function()
            require('mini.diff').setup({
              view = {
                style = "sign",
                signs = {
                  add = "▎",
                  change = "▎",
                  delete = "▁",
                },
                priority = 199,
              },
              mappings = {
                apply = "<leader>ha",
                reset = "<leader>hr",
                textobject = "gh",
                goto_first = "[H",
                goto_prev = "[h",
                goto_next = "]h",
                goto_last = "]H",
              },
              options = {
                algorithm = "histogram",
                indent_heuristic = true,
                linematch = 60,
              },
            })
          end,
        },
        
        -- Modern Git Interface
        {
          "NeogitOrg/neogit",
          dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
          },
          config = function()
            require('neogit').setup({
              disable_signs = false,
              disable_hint = false,
              disable_context_highlighting = false,
              auto_refresh = true,
              sort_branches = "-committerdate",
              integrations = {
                diffview = true,
                telescope = true,
              },
              sections = {
                untracked = {
                  folded = false,
                  hidden = false,
                },
                unstaged = {
                  folded = false,
                  hidden = false,
                },
                staged = {
                  folded = false,
                  hidden = false,
                },
                stashes = {
                  folded = true,
                  hidden = false,
                },
                unpulled = {
                  folded = true,
                  hidden = false,
                },
                unmerged = {
                  folded = false,
                  hidden = false,
                },
                recent = {
                  folded = true,
                  hidden = false,
                },
              },
            })
          end,
        },
        
        -- GitHub PR/Issue Management
        {
          "pwntester/octo.nvim",
          dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-tree/nvim-web-devicons",
          },
          config = function()
            require('octo').setup({
              use_local_fs = false,
              enable_builtin = true,
              default_remote = {"upstream", "origin"},
              default_merge_method = "commit",
              timeout = 5000,
              ui = {
                use_signcolumn = true,
              },
              issues = {
                order_by = {
                  field = "CREATED_AT",
                  direction = "DESC"
                }
              },
              pull_requests = {
                order_by = {
                  field = "CREATED_AT",
                  direction = "DESC"
                },
                always_select_remote_on_create = false
              },
              file_panel = {
                size = 10,
                use_icons = true
              },
            })
          end,
        },
        
        -- Git Conflict Resolution
        {
          "akinsho/git-conflict.nvim",
          version = "*",
          config = function()
            require('git-conflict').setup({
              default_mappings = true,
              default_commands = true,
              disable_diagnostics = false,
              list_opener = 'copen',
              highlights = {
                incoming = 'DiffAdd',
                current = 'DiffText',
              }
            })
          end,
        },
        
        { "tpope/vim-fugitive" },
        
        -- UI
        {
          "nvim-lualine/lualine.nvim",
          dependencies = { "nvim-tree/nvim-web-devicons" },
          config = function()
            require('lualine').setup {
              options = { theme = 'catppuccin' },
            }
          end,
        },
        {
          "akinsho/bufferline.nvim",
          dependencies = "nvim-tree/nvim-web-devicons",
          config = function()
            require('bufferline').setup {
              options = {
                diagnostics = "nvim_lsp",
                show_buffer_close_icons = true,
                show_close_icon = true,
                separator_style = "slant",
                offsets = {
                  {
                    filetype = "neo-tree",
                    text = "File Explorer",
                    highlight = "Directory",
                    text_align = "left"
                  }
                },
                diagnostics_indicator = function(count, level, diagnostics_dict, context)
                  local icon = level:match("error") and " " or " "
                  return " " .. icon .. count
                end,
                custom_filter = function(buf_number, buf_numbers)
                  -- Filter out file types you don't want to see
                  if vim.bo[buf_number].filetype ~= "qf" then
                    return true
                  end
                end,
              }
            }
          end,
        },
        
        -- Editing
        { "windwp/nvim-autopairs", config = true },
        { "numToStr/Comment.nvim", config = true },
        { "lukas-reineke/indent-blankline.nvim", main = "ibl", config = true },
        
        -- Formatting
        {
          "stevearc/conform.nvim",
          config = function()
            require("conform").setup({
              formatters_by_ft = {
                markdown = { "prettier_markdown" },
                javascript = { "prettier_code" },
                typescript = { "prettier_code" },
                json = { "prettier_code" },
                yaml = { "prettier_code" },
                html = { "prettier_code" },
                css = { "prettier_code" },
              },
              formatters = {
                prettier_markdown = {
                  command = "prettier",
                  args = { "--print-width", "80", "--prose-wrap", "always", "--stdin-filepath", "$FILENAME" },
                },
                prettier_code = {
                  command = "prettier",
                  args = { "--print-width", "120", "--stdin-filepath", "$FILENAME" },
                },
              },
              format_on_save = false,
            })
          end,
        },
        
        -- SpaceVim-style features
        {
          "folke/which-key.nvim",
          event = "VeryLazy",
          config = function()
            local wk = require("which-key")
            wk.setup()
            
            -- SpaceVim-style bindings (new format)
            wk.add({
              { "<leader> ", "<cmd>Telescope find_files<cr>", desc = "Find files" },
              { "<leader>f", group = "File" },
              { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
              { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
              { "<leader>fs", "<cmd>w<cr>", desc = "Save file" },
              { "<leader>fe", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
              { "<leader>s", group = "Search" },
              { "<leader>ss", "<cmd>Telescope live_grep<cr>", desc = "Search text" },
              { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Search files" },
              { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
              { "<leader>sr", "<cmd>lua require('spectre').open()<cr>", desc = "Search & Replace" },
              { "<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", desc = "Search current word" },
              { "<leader>sp", "<cmd>lua require('spectre').open_file_search({select_word=true})<cr>", desc = "Search in current file" },
              { "<leader>b", group = "Buffer" },
              { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Switch buffer" },
              { "<leader>bd", "<cmd>bd<cr>", desc = "Delete buffer" },
              { "<leader>bn", "<cmd>bnext<cr>", desc = "Next buffer" },
              { "<leader>bp", "<cmd>bprev<cr>", desc = "Previous buffer" },
              { "<leader>w", group = "Window" },
              { "<leader>wh", "<C-w>h", desc = "Move left" },
              { "<leader>wj", "<C-w>j", desc = "Move down" },
              { "<leader>wk", "<C-w>k", desc = "Move up" },
              { "<leader>wl", "<C-w>l", desc = "Move right" },
              { "<leader>ws", "<cmd>split<cr>", desc = "Split horizontal" },
              { "<leader>wv", "<cmd>vsplit<cr>", desc = "Split vertical" },
              { "<leader>wd", "<cmd>q<cr>", desc = "Close window" },
              { "<leader>g", group = "Git" },
              { "<leader>gs", "<cmd>Neogit<cr>", desc = "Status (Neogit)" },
              { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Commits" },
              { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Branches" },
              { "<leader>gd", "<cmd>lua MiniDiff.toggle_overlay()<cr>", desc = "Toggle Diff Overlay" },
              { "<leader>go", "<cmd>Octo<cr>", desc = "GitHub (Octo)" },
              { "<leader>gp", "<cmd>Octo pr list<cr>", desc = "List PRs" },
              { "<leader>gi", "<cmd>Octo issue list<cr>", desc = "List Issues" },
              { "<leader>h", group = "Hunks (Mini.diff)" },
              { "<leader>ha", desc = "Apply hunk" },
              { "<leader>hr", desc = "Reset hunk" },
              { "<leader>l", group = "LSP" },
              { "<leader>ld", "<cmd>Telescope lsp_definitions<cr>", desc = "Definitions" },
              { "<leader>lr", "<cmd>Telescope lsp_references<cr>", desc = "References" },
              { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code action" },
              { "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>", desc = "Format" },
              { "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
              { "<leader>lx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
              { "<leader>lX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
              { "<leader>ls", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
              { "<leader>ll", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions" },
              { "<leader>lL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
              { "<leader>lQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
              { "<leader>t", group = "Terminal" },
              { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
              { "<leader>m", group = "MCP" },
              { "<leader>ms", "<cmd>MCPStart<cr>", desc = "Start MCP Server" },
              { "<leader>mq", "<cmd>MCPStop<cr>", desc = "Stop MCP Server" },
              { "<leader>mt", "<cmd>MCPToggle<cr>", desc = "Toggle MCP Server" },
              { "<leader>mx", "<cmd>MCPStatus<cr>", desc = "MCP Status" },
              { "<leader>md", "<cmd>MCPDebug<cr>", desc = "MCP Debug Info" },
              { "<leader>c", group = "Code" },
              { "<leader>cf", "<cmd>lua require('conform').format()<cr>", desc = "Format file" },
              { "<leader>p", group = "Preview" },
              { "<leader>pm", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown preview" },
              { "<leader>mq", group = "Quit" },
              { "<leader>qq", "<cmd>q<cr>", desc = "Quit" },
              { "<leader>qQ", "<cmd>qa<cr>", desc = "Quit all" },
            })
          end,
        },
        { "mhinz/vim-startify" },
        { "easymotion/vim-easymotion" },
        { "justinmk/vim-sneak" },
        { "tpope/vim-surround" },
        
        -- Markdown Preview (render in-neovim)
        {
          "MeanderingProgrammer/render-markdown.nvim",
          opts = {
            file_types = { "markdown", "md" },
            heading = {
              sign = true,
              icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
              position = "overlay",
            },
            code = {
              sign = true,
              style = "full",
              position = "left",
              language_pad = 2,
              disable_background = { "diffview", "fugitive", "neo-tree" },
            },
            dash = {
              enabled = true,
              icon = "—",
            },
            bullet = {
              icons = { "●", "○", "◆", "◇" },
            },
            checkbox = {
              checked = { icon = "✅", scope_highlight = "@markup.strikethrough" },
              unchecked = { icon = "⬜" },
            },
            quote = {
              icon = "▎",
              repeat_linebreak = true,
            },
            pipe_table = {
              border = {
                "┌", "┬", "┐",
                "├", "┼", "┤",
                "└", "┴", "┘",
              },
              alignment_indicator = "┬",
              head = "┌┬┐",
              row = "├┼┤",
              foot = "└┴┘",
            },
          },
          ft = { "markdown", "md" },
        },
        
        -- Terminal
        {
          "akinsho/toggleterm.nvim",
          config = function()
            require('toggleterm').setup {
              size = 20,
              open_mapping = [[<c-\>]],
              direction = "horizontal",
              shell = vim.o.shell,
            }
          end,
        },
        
        -- Global Search and Replace (VS Code-like)
        {
          "nvim-pack/nvim-spectre",
          dependencies = { "nvim-lua/plenary.nvim" },
          config = function()
            require('spectre').setup({
              color_devicons = true,
              highlight = {
                ui = "String",
                search = "DiffChange",
                replace = "DiffDelete"
              },
              mapping = {
                ['toggle_line'] = {
                  map = "dd",
                  cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
                  desc = "toggle current item"
                },
                ['enter_file'] = {
                  map = "<cr>",
                  cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
                  desc = "goto current file"
                },
                ['send_to_qf'] = {
                  map = "<leader>q",
                  cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
                  desc = "send all item to quickfix"
                },
                ['replace_cmd'] = {
                  map = "<leader>c",
                  cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
                  desc = "input replace vim command"
                },
                ['show_option_menu'] = {
                  map = "<leader>o",
                  cmd = "<cmd>lua require('spectre').show_options()<CR>",
                  desc = "show option"
                },
                ['run_replace'] = {
                  map = "<leader>R",
                  cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
                  desc = "replace all"
                },
                ['change_view_mode'] = {
                  map = "<leader>v",
                  cmd = "<cmd>lua require('spectre').change_view()<CR>",
                  desc = "change result view mode"
                },
                ['toggle_ignore_case'] = {
                  map = "ti",
                  cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
                  desc = "toggle ignore case"
                },
                ['toggle_ignore_hidden'] = {
                  map = "th",
                  cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
                  desc = "toggle search hidden"
                },
              },
            })
          end,
        },
        
        -- Multi-cursor Support (VS Code-like)
        { "mg979/vim-visual-multi" },
        
        -- Better Diagnostics Panel (VS Code-like)
        {
          "folke/trouble.nvim",
          dependencies = { "nvim-tree/nvim-web-devicons" },
          config = function()
            require('trouble').setup({
              position = "bottom",
              height = 10,
              width = 50,
              icons = true,
              mode = "workspace_diagnostics",
              fold_open = "",
              fold_closed = "",
              group = true,
              padding = true,
              action_keys = {
                close = "q",
                cancel = "<esc>",
                refresh = "r",
                jump = {"<cr>", "<tab>"},
                open_split = {"<c-x>"},
                open_vsplit = {"<c-v>"},
                open_tab = {"<c-t>"},
                jump_close = {"o"},
                toggle_mode = "m",
                toggle_preview = "P",
                hover = "K",
                preview = "p",
                close_folds = {"zM", "zm"},
                open_folds = {"zR", "zr"},
                toggle_fold = {"zA", "za"},
                previous = "k",
                next = "j"
              },
              indent_lines = true,
              auto_open = false,
              auto_close = false,
              auto_preview = true,
              auto_fold = false,
              auto_jump = {"lsp_definitions"},
              signs = {
                error = "",
                warning = "",
                hint = "",
                information = "",
                other = "﫠"
              },
              use_diagnostic_signs = false
            })
          end,
        },
        
        -- MCP Server for AI Integration
        {
          "rhnvrm/nvim-claudecode-mcp",
          dependencies = {
            "echasnovski/mini.diff",
          },
          event = "VeryLazy",
          config = function()
            require("nvim-claudecode-mcp").setup({
              port_range = { min = 3000, max = 3999 },
              auto_start = true,
              selection_tracking = true,
              diff = {
                backend = "mini_diff", -- Use mini.diff for unified inline diffs
              },
            })
          end,
          keys = {
            { "<leader>m", group = "MCP" },
            { "<leader>ms", "<cmd>MCPStart<cr>", desc = "Start MCP Server" },
            { "<leader>mq", "<cmd>MCPStop<cr>", desc = "Stop MCP Server" },
            { "<leader>mt", "<cmd>MCPToggle<cr>", desc = "Toggle MCP Server" },
            { "<leader>mx", "<cmd>MCPStatus<cr>", desc = "MCP Status" },
            { "<leader>md", "<cmd>MCPDebug<cr>", desc = "MCP Debug Info" },
          },
        },
      })

      -- Additional keymaps
      vim.keymap.set('i', 'jk', '<Esc>')
      vim.keymap.set('i', 'kj', '<Esc>')
      vim.keymap.set('n', 'H', '^')
      vim.keymap.set('n', 'L', '$')
      vim.keymap.set('n', 'J', '5j')
      vim.keymap.set('n', 'K', '5k')

      -- Diagnostic keymaps
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float)

      -- Markdown formatting
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.textwidth = 80
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.formatoptions:append("t")
        end,
      })
    '';
  };
}
