local special_filetypes = require("utils").special_filetypes

return {

  -- Color column to indicate too long lines
  {
    -- https://github.com/m4xshen/smartcolumn.nvim
    "m4xshen/smartcolumn.nvim",
    enabled = false,
    opts = {
      colorcolumn = { "88" },
      disabled_filetypes = special_filetypes,
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
        tab_char = "┊",
      },
      viewport_buffer = {
        min = 500,
      },
      scope = { enabled = false },
      exclude = {
        filetypes = special_filetypes,
      },
    },
    main = "ibl",
    init = function()
      vim.keymap.set(
        "n",
        "<leader>ui",
        function()
          local has_ids, ids = pcall(require, "mini.indentscope")
          if vim.b.miniindentscope_disable then
            vim.cmd("IBLEnable")
            if has_ids then
              vim.b.miniindentscope_disable = false
              ids.draw()
            end
          else
            vim.cmd("IBLDisable")
            if has_ids then
              vim.b.miniindentscope_disable = true
              ids.draw()
            end
          end
          if not has_ids then
            vim.cmd("redraw")
          end
        end,
        { desc = "Toggle indentation lines" }
      )
    end,
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
        pattern = special_filetypes,
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },

}
