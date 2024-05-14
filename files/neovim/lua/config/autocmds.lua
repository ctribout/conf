-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

local function augroup(name)
  return vim.api.nvim_create_augroup("augroup_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Special treatment for special filetypes (close with <q>, no colorcolumn, ...)
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = require("utils").special_filetypes,
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    vim.opt_local.colorcolumn = ""
  end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown", "restructuredtext" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- enforce textwidth = 88 for Python
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("tw_py"),
  pattern = { "python" },
  callback = function(event)
    vim.b.editorconfig = false
    vim.opt_local.textwidth = 88
  end,
})

-- enforce textwidth = 80 for git commit messages
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("tw_git"),
  pattern = { "gitcommit" },
  callback = function(event)
    vim.b.editorconfig = false
    vim.opt_local.textwidth = 80
  end,
})

-- Display the cursor line only in the active window
vim.api.nvim_create_augroup("CursorLineOnlyInActiveWindow", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
  group = "CursorLineOnlyInActiveWindow",
  desc = "Enable cursorline in active window",
  command = "setlocal cursorline"
})
vim.api.nvim_create_autocmd("WinLeave", {
  group = "CursorLineOnlyInActiveWindow",
  desc = "Disable cursorline when leaving window",
  callback = function(event)
    if vim.bo.filetype ~= "neo-tree" then
      vim.cmd("setlocal nocursorline")
    end
  end,
})

-- Better new terminal windows
vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Config terminal and go to insert mode",
  command = "setlocal nonumber norelativenumber nospell | startinsert",
})
vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Set terminal to insert mode when going back to its window",
  group = termgroup,
  pattern = "term://*",
  command = "startinsert",
})

