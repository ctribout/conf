local utils = require("utils")

return {

  -- windows picker, used for neotree to choose where to open a file with 'w'
  {
    -- https://github.com/s1n7ax/nvim-window-picker
    "s1n7ax/nvim-window-picker",
    lazy = true,
    opts = {
      hint = 'floating-big-letter',
      filter_rules = {
        bo = {
          filetype = utils.special_filetypes,
        },
      },
    },
  },

  -- file explorer
  {
    -- https://github.com/nvim-neo-tree/neo-tree.nvim
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      -- TODO: resize after open/close/toggle, or only the first window is changed
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ dir = require("utils").find_project_dir() })
          local current_tab = vim.fn.tabpagenr()
          vim.cmd("tabdo wincmd =")
          vim.cmd("tabnext " .. current_tab)
        end,
        desc = "Explorer NeoTree (Root Dir)",
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ dir = vim.uv.cwd() })
          local current_tab = vim.fn.tabpagenr()
          vim.cmd("tabdo wincmd =")
          vim.cmd("tabnext " .. current_tab)
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      {
        "<leader>ft",
        function()
          require("neo-tree.command").execute(
            { toggle = true, action = "show", dir = require("utils").find_project_dir() }
          )
          local current_tab = vim.fn.tabpagenr()
          vim.cmd("tabdo wincmd =")
          vim.cmd("tabnext " .. current_tab)
        end,
        desc = "Toggle NeoTree (Root Dir)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (Root Dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
      { "<leader>t", "<leader>ft", desc = "Toggle NeoTree", remap = true },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status" })
        end,
        desc = "Git Explorer",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers" })
        end,
        desc = "Buffer Explorer",
      },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.uv.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_by_pattern = {
            ".*_cache",
            ".env",
            "env",
            ".git",
            ".pyenv",
            "pyenv",
            ".venv",
            "venv",
          },
        },
        use_libuv_file_watcher = true,
      },
      window = {
        mappings = {
          ["<space>"] = "none",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end,
            desc = "Copy Path to Clipboard",
          },
          ['e'] = function() vim.api.nvim_exec('Neotree focus filesystem left', true) end,
          ['b'] = function() vim.api.nvim_exec('Neotree focus buffers left', true) end,
          ['g'] = function() vim.api.nvim_exec('Neotree focus git_status left', true) end,
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        modified = {
          symbol = "󱗓"
        },
        git_status = {
          symbols = {
            added = "✚",
            modified = "",
            untracked = "",
            ignored = "",
            unstaged = "󰄱",
            staged = "",
            conflict = "",
          }
        }
      },
    },
  },

  -- search/replace in multiple files
  {
    -- https://github.com/nvim-pack/nvim-spectre
    "nvim-pack/nvim-spectre",
    build = false,
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    -- stylua: ignore
    keys = {
      { "<leader>sr", function() require("spectre").open({ cwd = require("utils").find_project_dir() }) end, desc = "Replace in Files (Spectre)" },
    },
  },

  -- Fuzzy finder.
  -- The default key bindings to find files will use Telescope's
  -- `find_files` or `git_files` depending on whether the
  -- directory is a git repo.
  {
     -- https://github.com/nvim-telescope/telescope.nvim
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        -- https://github.com/nvim-lua/plenary.nvim
        "nvim-lua/plenary.nvim",
        lazy = true,
      },
    },
    cmd = "Telescope",
    version = false, -- telescope did only one release, so use HEAD for now
    keys = {
      {
        "<leader>,",
        "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
        desc = "Switch Buffer",
      },
      { "<leader>/", function() require("telescope.builtin")["live_grep"]({ cwd = require("utils").find_project_dir() }) end, desc = "Grep (Root Dir)" },

      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      -- find
      { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
      { "<leader>ff", function() require("telescope.builtin")["find_files"]({ cwd = require("utils").find_project_dir() }) end, desc = "Find Files (Root Dir)" },
      { "<leader>fF", function() require("telescope.builtin")["find_files"]({ cwd = False }) end, desc = "Find Files (cwd)" },
      { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
      -- search
      { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
      { "<leader>sg", function() require("telescope.builtin")["live_grep"]({ cwd = require("utils").find_project_dir() }) end, desc = "Grep (Root Dir)" },
      { "<leader>sG", function() require("telescope.builtin")["live_grep"]({ cwd = False }) end, desc = "Grep (cwd)" },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
      { "<leader>sw", function() require("telescope.builtin")["grep_string"]({ word_match = "-w" }) end, desc = "Word (Root Dir)" },
      { "<leader>sW", function() require("telescope.builtin")["grep_string"]({ cwd = false, word_match = "-w" }) end, desc = "Word (cwd)" },
      { "<leader>sw", function() require("telescope.builtin")["grep_string"]() end, mode = "v", desc = "Selection (Root Dir)" },
      { "<leader>sW", function() require("telescope.builtin")["grep_string"]({ cwd = false }) end, mode = "v", desc = "Selection (cwd)" },
      { "<leader>uC", function() require("telescope.builtin")["colorscheme"]({ enable_preview = true }) end, desc = "Colorscheme with Preview" },
      { "<leader>ss", "<cmd>Telescope aerial<cr>", desc = "Goto Symbol (Aerial)" },
      {
        "<leader>sS",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols()
        end,
        desc = "Goto Symbol (Workspace)",
      },
    },
    opts = function()
      require("telescope").load_extension("aerial")
      local actions = require("telescope.actions")

      local open_with_trouble = function(...)
        return require("trouble.providers.telescope").open_with_trouble(...)
      end
      local open_selected_with_trouble = function(...)
        return require("trouble.providers.telescope").open_selected_with_trouble(...)
      end
      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          -- open files in the first window that is an actual file.
          -- use the current window if no other window is available.
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "" then
                return win
              end
            end
            return 0
          end,
          mappings = {
            i = {
              ["<c-t>"] = open_with_trouble,
              ["<a-t>"] = open_selected_with_trouble,
              ["<a-i>"] = find_files_no_ignore,
              ["<a-h>"] = find_files_with_hidden,
              ["<C-Down>"] = actions.cycle_history_next,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-b>"] = actions.preview_scrolling_up,
            },
            n = {
              ["q"] = actions.close,
            },
          },
          path_display = {
            absolute = true,
            filename_first = { reverse_directories = false },
            truncate = 3,
          },
        },
      }
    end,
  },

  -- C port of fzf for telescope
  {
    -- https://github.com/nvim-telescope/telescope-fzf-native.nvim
    "nvim-telescope/telescope-fzf-native.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    build = vim.fn.executable("make") == 1 and "make"
      or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    enabled = vim.fn.executable("make") == 1 or vim.fn.executable("cmake") == 1,
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },

  -- better diagnostics list and others
  {
    -- https://github.com/folke/trouble.nvim
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
      { "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").previous({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Previous Trouble/Quickfix Item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Next Trouble/Quickfix Item",
      },
    },
  },

  -- finds and lists all of the TODO, HACK, BUG, etc comment
  -- in your project and loads them into a browsable list.
  {
    -- https://github.com/folke/todo-comments.nvim
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    config = true,
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
  },

  -- code outline window for skimming and quick navigation
  {
    "stevearc/aerial.nvim",
    -- https://github.com/stevearc/aerial.nvim
    event = "VeryLazy",
    opts = function()
      local icons = require("utils").icons.kinds

      -- HACK: fix lua's weird choice for `Package` for control
      -- structures like if/else/for/etc.
      icons.lua = { Package = icons.Control }

      local opts = {
        manage_folds = false,
        attach_mode = "global",
        close_on_select = true,
        backends = { "lsp", "treesitter", "markdown", "man" },
        filter_kind = false,
        show_guides = true,
        layout = {
          resize_to_content = false,
          win_opts = {
            winhl = "Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
            signcolumn = "yes",
            statuscolumn = " ",
          },
        },
        icons = icons,
        guides = {
          mid_item   = "├╴",
          last_item  = "└╴",
          nested_top = "│ ",
          whitespace = "  ",
        },
      }
      return opts
    end,
    keys = {
      { "<leader>cs", "<cmd>AerialToggle<cr>", desc = "Aerial (Symbols)" },
    },
  },


}
