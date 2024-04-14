return {

  -- Color column to indicate too long lines
  {
    -- https://github.com/m4xshen/smartcolumn.nvim
    "m4xshen/smartcolumn.nvim",
    opts = {
      colorcolumn = { "88" },
      disabled_filetypes = {
        "NvimTree",
        "lazy",
        "mason",
        "help",
        "checkhealth",
        "lspinfo",
        "noice",
        "Trouble",
        "fish",
        "zsh",
      },
      custom_colorcolumn = {},
      scope = "file",  -- can be "file", "window" or "line"
    },
  },

  -- indent guides
  {
    -- https://github.com/lukas-reineke/indent-blankline.nvim
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      viewport_buffer = {
        min = 500,
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    },
    main = "ibl",
  },

  -- Special guide for current scope/indent level
  {
    -- https://github.com/echasnovski/mini.indentscope
    "echasnovski/mini.indentscope",
    opts = {
      symbol = "│",  -- "▏"
      options = { try_as_border = true },
      draw = { animation = function(s, n) return 0 end, },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

}
