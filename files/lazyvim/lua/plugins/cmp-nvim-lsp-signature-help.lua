-- Auto completion plugin for function parameters/doc

return {
  "hrsh7th/cmp-nvim-lsp-signature-help",
  init = function()
    require'cmp'.setup {
      sources = {
        { name = 'nvim_lsp_signature_help' },
        { name = "nvim_lsp" },
        { name = "buffer", keyword_length = 5 },
        { name = "path" },
      }
    }
  end,
}
