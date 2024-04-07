return {

  -- icons
  {
     -- https://github.com/nvim-tree/nvim-web-devicons
     "nvim-tree/nvim-web-devicons",
     lazy = true,
   },

  -- colorscheme
  {
     -- https://github.com/catppuccin/nvim
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      background = {
        light = "latte",
        dark = "mocha",
      },
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
      styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" },
        conditionals = { "bold" },
        loops = { "bold" },
        functions = {},
        keywords = { "bold" },
        strings = {},
        variables = {},
        numbers = {},
        booleans = { "bold" },
        properties = {},
        types = {},
        operators = { "bold" },
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
      },
      dim_inactive = {
        -- Dims the background color of inactive windows, going toward the "mantle" color
        -- in "dark" mode
        enabled = true, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.4, -- [0-1], the lowest the closest to "mantle"
      },
      color_overrides = {
        mocha = {
          -- https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/palettes/mocha.lua
          base = "#1e1e2e", -- main background color (active) [default]
          mantle = "#12121b", -- status bar, and context top view [darker]
          crust = "#09090f",  -- darkest background [darker]
          text = "#e6e9ff",  -- [lighter]
          lavender = "#bec8fe",  -- [lighter]
        },
      },
      custom_highlights = function(colors)

        local c_identifier = colors.text
        local c_constant = colors.yellow
        local c_string = colors.rosewater
        local c_number = colors.flamingo
        local c_character = colors.flamingo
        local c_operator = colors.maroon
        local c_keyword = colors.red
        local c_type = colors.mauve
        local c_function = colors.lavender
        local c_macro = colors.teal
        local c_bracket = colors.subtext1

        return {
          -- To see the highlight group use for a character, use ":Inspect" on recent nvim 

          -- Defaults here:
          -- https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups/syntax.lua

          WinSeparator = { fg = colors.overlay1 }, -- make windows vertical/horizontal separator lines a bit more visible
          Character = { fg = c_character, style = { "bold" } },
          String = { fg = c_string },
          Number = { fg = c_number },
          Float = { link = "Number" },
          Constant = { fg = c_constant },
          Identifier = { fg = c_identifier },
          Type = { fg = c_type },
          Function = { fg = c_function },
          Operator = { fg = c_operator, style = { "bold" } },
          Boolean = { link = "Operator" },  -- true/false
          Keyword = { fg = c_keyword, style = { "bold" } },  -- def/class
          Conditional = { link = "Keyword" }, -- if/else/elif
          Exception = { link = "Keyword" },  -- try/except/raise/finally
          Repeat = { link = "Keyword" },  -- for/while
          Include = { link = "Keyword" },  -- import

          -- Redefine most of tree-sitter specific highlights: the code is a terrible rainbow with the default settings
          -- base: https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups/integrations/treesitter.lua

          -- Identifiers
          ["@variable"] = { link = "Identifier" },
          ["@variable.parameter"] = { link = "Identifier" },
          ["@variable.member"] = { link = "Identifier" },
          ["@variable.builtin"] = { fg = c_identifier, style = { "bold" } },
          ["@constant"] = { link = "Constant" },
          ["@constant.builtin"] = { fg = c_constant, style = { "bold" } },
          ["@module"] = { link = "Constant" },

          -- Literals
          ["@string"] = { link = "String" },
          ["@string.documentation"] = { fg = colors.overlay2, style = { "italic" } },
          ["@string.escape"] = { link = "Character" },
          ["@string.special"] = { link = "String" },
          ["@string.special.path"] = { link = "String" },
          ["@string.special.symbol"] = { link = "String" },
          ["@string.special.url"] = { fg = c_string, style = { "italic", "underline" } },
          ["@character"] = { link = "Character" },
          ["@character.special"] = { link = "Character" },
          ["@boolean"] = { link = "Boolean" },
          ["@number"] = { link = "Number" },
          ["@number.float"] = { link = "Float" },

          -- Types
          ["@type"] = { link = "Type" },
          ["@type.builtin"] = { fg = c_type, style = { "bold" } },
          ["@type.definition"] = { link = "Type" },
          ["@attribute"] = { fg = c_operator }, -- attribute annotations (e.g. Python decorators)
          ["@property"] = { link = "@attribute" },

          -- Functions
          ["@function"] = { link = "Function" },
          ["@function.builtin"] = { fg = c_function, style = { "bold" } },
          ["@function.call"] = { link = "Function" },
          ["@function.macro"] = { fg = c_macro },
          ["@function.method"] = { link = "Function" },
          ["@function.method.call"] = { link = "Function" },
          ["@constructor"] = { link = "Type" },
          ["@operator"] = { link = "Operator" },

          -- Keywords
          ["@keyword"] = { link = "Keyword" },
          ["@keyword.modifier"] = { link = "Keyword" },
          ["@keyword.type"] = { link = "Keyword" },
          ["@keyword.coroutine"] = { link = "Keyword" },
          ["@keyword.function"] = { link = "Keyword" },
          ["@keyword.operator"] = { link = "Operator" },
          ["@keyword.import"] = { link = "Include" },
          ["@keyword.repeat"] = { link = "Repeat" },
          ["@keyword.return"] = { link = "Keyword" },
          ["@keyword.debug"] = { link = "Keyword" },
          ["@keyword.exception"] = { link = "Exception" },
          ["@keyword.conditional"] = { link = "Conditional" },
          ["@keyword.conditional.ternary"] = { link = "Operator" },
          ["@keyword.directive"] = { link = "PreProc" },
          ["@keyword.directive.define"] = { link = "Define" },

		  -- Punctuation
		  ["@punctuation.delimiter"] = { link = "String" },
		  ["@punctuation.bracket"] = { fg = c_bracket },
		  ["@punctuation.special"] = { link = "Character" },

          -- Regexps
          ["@constant.regex"] = { link = "String" },
          ["@string.regexp"] = { link = "String" },
          ["@operator.regex"] = { link = "Character" },
          ["@punctuation.bracket.regex"] = { link = "Character" },

          -- Python-specific overload
          ["@keyword.directive.python"] = { link = "Comment" }, -- shebang
        }
      end,
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme "catppuccin"
    end,
  },

}
