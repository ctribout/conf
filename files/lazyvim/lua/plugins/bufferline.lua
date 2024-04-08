return {
  {
    "akinsho/bufferline.nvim",
    dependencies = { "catppuccin/nvim" }, -- needed because its colors are referenced
    opts = function(_, opts)
      return {
        options = {
          always_show_bufferline = true,
          modified_icon = '',
          show_buffer_close_icons = false,
          show_close_icon = false,
          separator_style = "thick",
          diagnostics = false,
        },
        highlights = {
          modified = {
            fg = vim.api.nvim_get_hl_by_name('ErrorMsg', true).foreground,
          },
          modified_visible = {
            fg = vim.api.nvim_get_hl_by_name('ErrorMsg', true).foreground,
          },
          modified_selected = {
            fg = vim.api.nvim_get_hl_by_name('ErrorMsg', true).foreground,
          },
        },
      }
    end,
  },
}
