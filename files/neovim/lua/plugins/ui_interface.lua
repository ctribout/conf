return {

  -- ui components (required by other plugins)
  {
    -- https://github.com/MunifTanjim/nui.nvim
    "MunifTanjim/nui.nvim",
    lazy = true,
  },

  -- top tab line with open buffers
  {
    -- https://github.com/akinsho/bufferline.nvim
    "akinsho/bufferline.nvim",
    dependencies = { "catppuccin/nvim" }, -- needed because its colors are referenced
    lazy = false,
    opts = function(_, opts)
      local mocha = require("catppuccin.palettes").get_palette("mocha")
      return {
        options = {
          always_show_bufferline = true,
          modified_icon = '󱗓', --  󱞂  󰳻 󰽂 󰳥 󱗓 󰈔  󰩋 
          show_buffer_close_icons = false,
          show_close_icon = false,
          separator_style = "thick",
          diagnostics = false,
          close_command = function(n) require("mini.bufremove").delete(n, false) end,
          offsets = {
            {
              filetype = "neo-tree",
              text = "Neo-tree",
              highlight = "Directory",
              text_align = "left",
            },
          },
        },
        highlights = {
          buffer_selected = {
            bold = true,
            italic = true,
          },
          modified = {
            fg = mocha.red,
          },
          modified_visible = {
            fg = mocha.red,
          },
          modified_selected = {
            fg = mocha.red,
            italic = true,
          },
          tab_selected = {
            bold = true,
            italic = true,
          }
        },
      }
    end,
    config = function(_, opts)
      require("bufferline").setup(opts)
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd("BufAdd", {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Delete Other Buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    },
  },

  -- bottom bar with various information on the current window
  {
    -- https://github.com/nvim-lualine/lualine.nvim
    "nvim-lualine/lualine.nvim",
    dependencies = { "catppuccin/nvim" }, -- needed because its colors are referenced
    opts = function(_, opts)
      -- diagnostics inspired by https://github.com/nvim-lualine/lualine.nvim/discussions/911
      local utils = require("lualine.utils.utils")
      local diagnostics_message = require("lualine.component"):extend()
      function diagnostics_message:update_status(is_focused)
        local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
        local diagnostics = vim.diagnostic.get(0, { lnum = r - 1 })
        if #diagnostics > 0 then
          local top = diagnostics[1]
          for _, d in ipairs(diagnostics) do
            if d.severity < top.severity then
              top = d
            end
          end
          -- lualine_c gets truncated first if too long, but it's the left part
          -- of the string that is lost, which is not convenient: truncate it on
          -- the right already, so that it's hopefully still readable a bit longer
          -- The value reserved for all other elements is empiric and should allow
          -- to have correct behavior in most cases
          local length_max = vim.fn.winwidth(0) - 45
          if length_max <= 0 then
            return ""
          end
          local message = top.message:gsub("\n.*","")
          if #message > length_max then
            message = string.sub(top.message, 1, length_max-3) .. "(…)"
          end
          return utils.stl_escape(message)
        else
          return ""
        end
      end
      return {
        sections = {
          lualine_a = {'mode'},
          lualine_b = {
            --{
            --  'filename',
            --  path = 4,
            --  symbols = {
            --    modified = '',
            --    readonly = '',
            --    newfile = '',
            --    unnamed = '󰋶'
            --  }
            --},
            -- 'branch',
            'diff',
            'diagnostics',
          },
          lualine_c = {
            {
              diagnostics_message,
              color = {
                gui = "italic",
                fg = string.format("%06x", vim.api.nvim_get_hl_by_name('Comment', true).foreground),
              },
            },
          },
          lualine_x = {
            {
              venv,
              color = {
                fg = string.format("%06x", vim.api.nvim_get_hl_by_name('Comment', true).foreground),
              },
            },
          },
          lualine_y = {
            'selectioncount',
            'searchcount',
            'progress',
          },
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            { 'filename', path = 3, shorting_target = 10 },
          },
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        options = {
          disabled_filetypes = {
            statusline = { 'help', 'neo-tree', 'aerial' },
          },
        },
      }
    end
  },

  -- git signs highlights text that has changed since the list
  -- git commit, and also lets you interactively stage & unstage
  -- hunks in a commit.
  {
    -- https://github.com/lewis6991/gitsigns.nvim
    "lewis6991/gitsigns.nvim",
    opts = {
      -- left aligned: ▏▎▍▌▋▊▉█  ︴
      -- center aligned: │┃ ╎╏┆┇┊┋║
      -- right aligned: ▕▐
      signs = {
        add = { text = "┃" },
        change = { text = "║" },
        delete = { text = "▁" },  -- ﹏ ⎵ ⎽ ▁ ▂
        topdelete = { text = "▔" }, -- ﹋ ⎴ ⎺ ▔
        changedelete = { text = "║" },
        untracked = { text = "┃" },
      },
      signs_staged_enable = true,
      numhl      = true,
      linehl     = false,
      word_diff  = false,
      current_line_blame = false,
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", function() gs.nav_hunk("next", { target = "all" }) end, "Next Hunk (all)")
        map("n", "[h", function() gs.nav_hunk("prev", { target = "all" }) end, "Prev Hunk (all)")
        map("n", "]H", function() gs.nav_hunk("next", { target = "unstaged" }) end, "Next Hunk (unstaged)")
        map("n", "[H", function() gs.nav_hunk("prev", { target = "unstaged" }) end, "Prev Hunk (unstaged)")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        -- map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line (full)")
        map("n", "<leader>ghB", function() gs.blame_line({ full = false }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map("n", "<leader>ght", gs.toggle_current_line_blame, "Toggle inline blame")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },

  -- TODO: replace with https://github.com/folke/snacks.nvim
  -- better vim.ui
  {
    -- https://github.com/stevearc/dressing.nvim
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim", -- Make Markdown buffers look beautiful
    ft = { "markdown", "codecompanion" },
    opts = {
      render_modes = true, -- Render in ALL modes
      sign = {
        enabled = false, -- Turn off in the status column
      },
      overrides = {
        filetype = {
          codecompanion = {
            html = {
              tag = {
                buf = { icon = " ", highlight = "CodeCompanionChatIcon" },
                file = { icon = " ", highlight = "CodeCompanionChatIcon" },
                group = { icon = " ", highlight = "CodeCompanionChatIcon" },
                help = { icon = "󰘥 ", highlight = "CodeCompanionChatIcon" },
                image = { icon = " ", highlight = "CodeCompanionChatIcon" },
                symbols = { icon = " ", highlight = "CodeCompanionChatIcon" },
                tool = { icon = "󰯠 ", highlight = "CodeCompanionChatIcon" },
                url = { icon = "󰌹 ", highlight = "CodeCompanionChatIcon" },
              },
            },
          },
        },
      },
    },
  },

}
