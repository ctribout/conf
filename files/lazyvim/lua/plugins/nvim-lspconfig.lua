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
    servers = {
      pyright = {
        -- see configuration section in
        -- https://github.com/microsoft/pyright/blob/main/packages/vscode-pyright/package.json
        settings = {
          python = {
            analysis = {
              -- disable auto completion entries that propose random content
              -- with the need for an extra imports added at the same time
              autoImportCompletions = false,
            },
          },
        },
      },
    },
  },
}
