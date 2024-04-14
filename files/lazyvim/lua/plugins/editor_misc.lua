local utils = require("utils")

return {

  -- Automatically highlights other instances of the word under your cursor.
  -- This works with LSP, Treesitter, and regexp matching to find the other
  -- instances.
  {
    -- https://github.com/RRethy/vim-illuminate
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    opts = {
      delay = 200,
      large_file_cutoff = 3000,
      large_file_overrides = {
        providers = {
          "lsp",
        }
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
  },

  -- buffer remove
  {
    -- https://github.com/echasnovski/mini.bufremove
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
    },
  },

  -- which-key helps you remember key bindings by showing a popup
  -- with the active keybindings of the command you started typing.
  {
    -- https://github.com/folke/which-key.nvim
    "folke/which-key.nvim",
    opts = {
      defaults = {
        mode = { "n", "v" },
        ["g"] = { name = "+goto" },
        ["gs"] = { name = "+surround" },
        ["z"] = { name = "+fold" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["<leader><tab>"] = { name = "+tabs" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>gh"] = { name = "+hunks" },
        ["<leader>q"] = { name = "+quit/session" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>u"] = { name = "+ui" },
        ["<leader>w"] = { name = "+windows" },
        ["<leader>x"] = { name = "+diagnostics/quickfix" },
      },
      window = {
        border = "double", -- none, single, double, shadow
        winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults)
      vim.keymap.set({"n",  "v"}, "<leader>k", "<cmd>WhichKey<cr>", { desc = "WhichKey" })
    end,
  },

  -- Toggle words
  {
    -- https://github.com/tandy1229/wordswitch.nvim
    "tandy1229/wordswitch.nvim",
    keys = { 
      { "<leader>t", "<cmd>:WordSwitch<cr>", desc = "Toggle word" },
    },
  },

  -- Move any selection in any direction
  {
    -- https://github.com/echasnovski/mini.move
    "echasnovski/mini.move",
    event = "VeryLazy",
    opts = {
      options = {
        reindent_linewise = false,
      },
    },
  },

  -- Fast and feature-rich surround actions
  {
    -- https://github.com/echasnovski/mini.surround
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = 'gsa', -- Add surrounding in Normal and Visual modes
        delete = 'gsd', -- Delete surrounding
        find = 'gsf', -- Find surrounding (to the right)
        find_left = 'gsF', -- Find surrounding (to the left)
        highlight = 'gsh', -- Highlight surrounding
        replace = 'gsr', -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`
        suffix_last = 'l', -- Suffix to search with "prev" method
        suffix_next = 'n', -- Suffix to search with "next" method
      },
    },
  },

  -- Extend and create a/i textobjects
  {
    -- https://github.com/echasnovski/mini.ai
    "echasnovski/mini.ai",
    opts = function()
      local ai = require("mini.ai")
      return {
        mappings = {
          goto_left = '',
          goto_right = '',
        },
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          g = function() -- Whole buffer, similar to `gg` and 'G' motion
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line("$"),
              col = math.max(vim.fn.getline("$"):len(), 1),
            }
            return { from = from, to = to }
          end,
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      -- register all text objects with which-key
      local i = {
        [" "] = "Whitespace",
        ['"'] = 'Balanced "',
        ["'"] = "Balanced '",
        ["`"] = "Balanced `",
        ["("] = "Balanced (",
        [")"] = "Balanced ) including white-space",
        [">"] = "Balanced > including white-space",
        ["<lt>"] = "Balanced <",
        ["]"] = "Balanced ] including white-space",
        ["["] = "Balanced [",
        ["}"] = "Balanced } including white-space",
        ["{"] = "Balanced {",
        ["?"] = "User Prompt",
        _ = "Underscore",
        a = "Argument",
        b = "Balanced ), ], }",
        c = "Class",
        d = "Digit(s)",
        e = "Word in CamelCase & snake_case",
        f = "Function",
        g = "Entire file",
        o = "Block, conditional, loop",
        q = "Quote `, \", '",
        t = "Tag",
        u = "Use/call function & method",
        U = "Use/call without dot in name",
      }
      local a = vim.deepcopy(i)
      for k, v in pairs(a) do
        a[k] = v:gsub(" including.*", "")
      end

      local ic = vim.deepcopy(i)
      local ac = vim.deepcopy(a)
      for key, name in pairs({ n = "Next", l = "Last" }) do
        i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
        a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
      end
      require("which-key").register({
        mode = { "o", "x" },
        i = i,
        a = a,
      })
    end,
  },

  -- set the commentstring option based on the cursor location in the file
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    -- https://github.com/JoosepAlviste/nvim-ts-context-commentstring
    lazy = true,
    opts = {
      enable_autocmd = false,
    },
  },

  -- code comments
  {
    "echasnovski/mini.comment",
    -- https://github.com/echasnovski/mini.comment
    event = "VeryLazy",
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },

}
