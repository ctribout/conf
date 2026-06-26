return {

  -- Treesitter parsers + queries. On Neovim 0.12 core ships the parsers but not
  -- the per-language highlight queries, so highlighting still comes from here.
  {
    -- https://github.com/nvim-treesitter/nvim-treesitter
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- the rewrite, for Nvim 0.11+ (master is frozen for 0.11)
    lazy = false, -- the main branch does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      -- the main branch compiles parsers with the `tree-sitter` CLI; without it
      -- every parser build fails, so warn once instead of erroring per language
      if vim.fn.executable("tree-sitter") == 1 then
        require("nvim-treesitter").install({
          "bash", "diff", "dockerfile", "gitcommit", "json", "lua", "markdown",
          "markdown_inline", "python", "query", "toml", "vim", "vimdoc", "yaml",
        })
      else
        vim.notify(
          "[treesitter] `tree-sitter` CLI not on PATH; parsers can't be built. "
            .. "Install tree-sitter-cli (npm/cargo/release binary).",
          vim.log.levels.WARN
        )
      end
      -- the main branch does not auto-start highlighting; enable it per buffer
      -- for any filetype whose parser is available
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },

  -- Treesitter textobject queries: restores mini.ai's @function/@class/@block
  -- objects (the `textobjects` query ships here, not in core)
  {
    -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
  },

  -- Sticky header showing the enclosing scope (class/function) of the cursor
  {
    -- https://github.com/nvim-treesitter/nvim-treesitter-context
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = {
      mode = "cursor",
      max_lines = 3,
      multiline_threshold = 1,
      trim_scope = "outer",
    },
    keys = {
      { "<leader>ut", function() require("treesitter-context").toggle() end, desc = "Toggle Context Header" },
    },
  },

}
