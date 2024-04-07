return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      virtual_text = false,
      update_in_insert = false,
      underline = true,
      float = {
        border = "single",
        source = true,
        suffix = "",
      },
    },
  },
}
