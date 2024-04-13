return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    indent = {
      enable = true,
      disable = { "python" },  -- Result is too bad on Python
    },
    highlight = {
      -- Note: seem to slow down nvim (chars slow to display) on big files
      enable = true,
      disable = {},
    },
    prefer_git = true,
    additional_vim_regex_highlighting = false,
  },
}
