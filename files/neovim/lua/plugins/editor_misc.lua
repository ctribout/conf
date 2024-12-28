local utils = require("utils")

local function dial(increment, g)
  dmap = require("dial.map")
  dcfg = require("dial.config")
  local is_visual = vim.fn.mode(true):sub(1, 1) == "v"
  local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
  local group = vim.bo.filetype
  local gdata = dcfg.augends:get(group)
  if not gdata then
    group = "default"
  end
  return dmap[func](group)
end

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
    event = "VeryLazy",
    opts = {
      win = {
        border = "double", -- none, single, double, shadow
        wo = {
          winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        {
          mode = { "n", "v" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>c", group = "code" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "hunks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
          { "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
          -- better descriptions
          { "gx", desc = "Open with system app" },

        },
      })
      vim.keymap.set({"n",  "v"}, "<leader>k", "<cmd>WhichKey<cr>", { desc = "WhichKey" })
    end,
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
      local objects = {
        { " ", desc = "whitespace" },
        { '"', desc = '" string' },
        { "'", desc = "' string" },
        { "(", desc = "() block" },
        { ")", desc = "() block with white-space" },
        { "<", desc = "<> block" },
        { ">", desc = "<> block with white-space" },
        { "?", desc = "user prompt" },
        { "U", desc = "use/call without dot" },
        { "[", desc = "[] block" },
        { "]", desc = "[] block with white-space" },
        { "_", desc = "underscore" },
        { "`", desc = "` string" },
        { "a", desc = "argument" },
        { "b", desc = ")]} block" },
        { "c", desc = "class" },
        { "d", desc = "digit(s)" },
        { "e", desc = "CamelCase / snake_case" },
        { "f", desc = "function" },
        { "g", desc = "entire file" },
        { "i", desc = "indent" },
        { "o", desc = "block, conditional, loop" },
        { "q", desc = "quote `\"'" },
        { "t", desc = "tag" },
        { "u", desc = "use/call" },
        { "{", desc = "{} block" },
        { "}", desc = "{} with white-space" },
      }
      local ret = { mode = { "o", "x" } }
      local mappings = {
        around = "a",
        inside = "i",
        around_next = "an",
        inside_next = "in",
        around_last = "al",
        inside_last = "il",
        goto_left = nil,
        goto_right = nil,
      }

      for name, prefix in pairs(mappings) do
        name = name:gsub("^around_", ""):gsub("^inside_", "")
        ret[#ret + 1] = { prefix, group = name }
        for _, obj in ipairs(objects) do
          local desc = obj.desc
          if prefix:sub(1, 1) == "i" then
            desc = desc:gsub(" with white-space", "")
          end
          ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
        end
      end
      require("which-key").add(ret, { notify = false })
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

  -- Focus on a windows or on on certain part of it
  {
    "pocco81/true-zen.nvim",
    -- https://github.com/pocco81/true-zen.nvim
    keys = {
      {
        "<leader>z",
        function()
          require("true-zen").focus()
        end,
        desc = "True Zen (focus)",
      },
    },
  },

  -- increment/decrement values
  {
    "monaqa/dial.nvim",
    -- https://github.com/monaqa/dial.nvim
    keys = {
        { "<C-a>", function() return dial(true) end, expr = true, desc = "Increment", mode = {"n", "v"} },
        { "<C-x>", function() return dial(false) end, expr = true, desc = "Decrement", mode = {"n", "v"} },
        { "g<C-a>", function() return dial(true, true) end, expr = true, desc = "Increment", mode = {"n", "v"} },
        { "g<C-x>", function() return dial(false, true) end, expr = true, desc = "Decrement", mode = {"n", "v"} },
    },
    config = function(_, opts)
      local augend = require("dial.augend")

      local logical_alias = augend.constant.new({
        elements = { "&&", "||" },
        word = false,
        cyclic = true,
      })
      local logical_ops = augend.constant.new({
        elements = { "and", "or" },
        word = true,
        cyclic = true,
      })

      local ordinal_numbers = augend.constant.new({
        -- elements through which we cycle. When we increment, we go down
        -- On decrement we go up
        elements = {
          "first",
          "second",
          "third",
          "fourth",
          "fifth",
          "sixth",
          "seventh",
          "eighth",
          "ninth",
          "tenth",
        },
        -- if true, it only matches strings with word boundary. firstDate wouldn't work for example
        word = false,
        -- do we cycle back and forth (tenth to first on increment, first to tenth on decrement).
        -- Otherwise nothing will happen when there are no further values
        cyclic = true,
      })

      local weekdays = augend.constant.new({
        elements = {
          "Monday",
          "Tuesday",
          "Wednesday",
          "Thursday",
          "Friday",
          "Saturday",
          "Sunday",
        },
        word = true,
        cyclic = true,
      })

      local months = augend.constant.new({
        elements = {
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December",
        },
        word = true,
        cyclic = true,
      })

      local capitalized_boolean = augend.constant.new({
        elements = {
          "True",
          "False",
        },
        word = true,
        cyclic = true,
      })

      local default = {
        augend.constant.alias.bool,
        augend.date.alias["%Y/%m/%d"],
        augend.hexcolor.new({ case = "lower" }),
        augend.hexcolor.new({ case = "upper" }),
        augend.integer.alias.binary,
        augend.integer.alias.decimal_int,
        augend.integer.alias.hex,
        augend.semver.alias.semver,
        capitalized_boolean,
        logical_alias,
        logical_ops,
        months,
        ordinal_numbers,
        weekdays,
      }
      -- note: can be extended for specific filetypes with { elt1, elt2, unpack(default) }
      -- ( or table.unpack in more recent lua versions)
      local groups = {
        default = default,
      }
      dcfg = require("dial.config")
      dcfg.augends:register_group(groups)
      dcfg.augends:register_group({
      -- aliases
      javascript = groups.typescript,
      javascriptreact = groups.typescript,
      sass = groups.css,
      scss = groups.css,
      typescriptreact = groups.typescript,
      })
    end,
  },

}
