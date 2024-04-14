-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.autoread = true  -- Auto read when a file is changed from the outside
vim.opt.autowrite = false
vim.opt.backup = false
vim.opt.writebackup = true
vim.opt.swapfile = false
vim.opt.autochdir = false  -- Impacts too many plugins (ex.: live previews)
vim.opt.foldmethod = "manual"
vim.opt.hidden = true
vim.opt.wrap = true -- Force line wrap
vim.opt.joinspaces = false -- Don't use two spaces when joining lines
vim.opt.showmatch = true
vim.opt.matchtime= 2  -- How many tenths of a second to blink when matching brackets
vim.opt.linebreak = false
vim.opt.formatoptions:append("q")
vim.opt.formatoptions:remove("c")
vim.opt.formatoptions:remove("t")
vim.opt.textwidth = 88
vim.opt.colorcolumn = "88"

vim.opt.mouse = ""
vim.g.behave = "xterm"
vim.opt.spelllang = { "en", "fr" }
vim.opt.number = true -- Print line number
vim.opt.relativenumber = false -- Relative line numbers

vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.shiftwidth = 4 -- 1 tab == 4 spaces
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftround = true -- Round indent
vim.opt.indentkeys:remove("o")
-- keep a single shift on a new line after a parenthesis in Python
vim.g.pyindent_open_paren = vim.bo.shiftwidth
vim.opt.whichwrap:append {
  -- Move to next/previous line with arrows at the edge of lines 
  ['<'] = true, ['>'] = true, ['['] = true, [']'] = true, h = false, l = false,
}

vim.g.autoformat = false -- disable auto-format on save

vim.opt.completeopt = "menu,menuone,noinsert,noselect"

-- root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`.
-- * a function with signature `function(buf) -> string|string[]`
vim.g.root_spec = { "lsp", { ".git", "lua", "pyproject.toml", "requirement.txt" }, "cwd" }

vim.opt.shortmess = "S"  -- don't display the searchcount [X/Y] in the statusbar
vim.opt.list = false -- don't display invisible chars (see vim.opt.listchars)
vim.cmd("match Error /\\s\\+$/")  -- highlight trailing empty chars as errors

-- The neovim :terminal command replaces the current split and then it gets
-- deleted when it is exited, so create a split first with a new Shell cmd
vim.api.nvim_create_user_command("Shell", "split +:terminal", {
  desc = "Launch a termain in a new horizontal split window",
})
vim.keymap.set("n", "<F10>", "<cmd>Shell<cr>", { desc = "Create a new terminal windows" })
vim.keymap.set("t", "<C-w>", "<C-\\><C-N><C-W>", { desc = "Leave a terminal windows like any other" } )
vim.keymap.set("v", "<C-r>", '"hy:%s@<C-r>h@@gc<left><left><left>', { desc = "Replace the current selection" })

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0

vim.bo.undolevels = 1000
vim.opt.history = 1000

vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitkeep = "screen"
vim.opt.splitright = true -- Put new windows right of current
vim.opt.termguicolors = true
vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
vim.opt.winminwidth = 5 -- Minimum window width
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.showmode = false -- Dont show mode since we have a statusline
vim.opt.sidescrolloff = 8 -- Columns of context
vim.opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
vim.opt.number = true -- Print line number
vim.opt.pumblend = 10 -- Popup blend
vim.opt.pumheight = 10 -- Maximum number of entries in a popup

-- Disable modeline feature (header in files like `# vim: <options>`)
vim.g.modelines = 0
vim.g.modeline = false

vim.g.matchparen_timeout = 2
vim.g.matchparen_insert_timeout = 2
vim.opt.matchpairs = "(:),{:},[:]"

vim.opt.foldlevel = 99
if vim.fn.has("nvim-0.9.0") == 1 then
  vim.opt.statuscolumn = [[%!v:lua.require'utils'.statuscolumn()]]
  -- vim.opt.foldtext = "v:lua.require'utils'.foldtext()"
end

-- vim.lsp.set_log_level("debug")
