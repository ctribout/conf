-- Neovim runs LuaJIT; `vim` is the editor API global (writable: config sets
-- vim.g/vim.bo/vim.ui.* etc.).
std = "luajit"
globals = { "vim" }
max_line_length = false
unused_args = false -- lazy.nvim / lualine callbacks have fixed signatures
