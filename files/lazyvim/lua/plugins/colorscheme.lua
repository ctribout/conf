return {
  {
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
      styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" },
        conditionals = { "bold" },
        loops = { "bold" },
        functions = {},
        keywords = { "bold" },
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = { "bold" },
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
      },
      dim_inactive = {
        enabled = true, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.1, -- percentage of the shade to apply to the inactive window
      },
      color_overrides = {
        mocha = {
          -- https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/palettes/mocha.lua
          base = "#282838",
          mantle = "#141424",
          text = "#e6e9ff",
          peach = "#c79e85",
        },
      },
      custom_highlights = function(colors)
        return {
          -- Defaults here:
          -- https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups/syntax.lua
          -- But overriden per language by treesitter integration, for more specific colors
          -- https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups/integrations/treesitter.lua
          WinSeparator = { fg = colors.overlay1 }, -- make windows vertical/horizontal separator lines a bit more visible
          String = { fg = colors.text },
          Number = { fg = colors.green },
        }
      end,
    },
  },
  -- Configure LazyVim to load catppuccin
  {
    "LazyVim/LazyVim",
    -- Seems important to have a low priority so that the customizations done above are
    -- always taken into account (otherwise they have no effect half of the time, randomly)
    priority = 10,
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
