return {

  -- Treesitter parser generator for faster and more accurate syntax highlighting
  {
    -- https://github.com/nvim-treesitter/nvim-treesitter
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      {
        -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
        "nvim-treesitter/nvim-treesitter-textobjects",
      },
    },
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment Selection" },
      { "<bs>", desc = "Decrement Selection", mode = "x" },
    },
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treesitter** module to be loaded in time.
      -- Luckily, the only things that those plugins need are the custom queries, which we make available
      -- during startup.
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    opts = {
      highlight = { enable = true },
      indent = { enable = false },  -- Result is too bad on Python
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitcommit",
        "json",
        "make",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "rst",
        "rust", 
        "toml",
        "xml",
        "yaml",
      },
      prefer_git = true,
      additional_vim_regex_highlighting = false,
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- Show context bar of the current function
  {
    -- https://github.com/nvim-treesitter/nvim-treesitter-context
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      mode = "cursor",
      max_lines = 3,
      line_numbers = true,
    },
  },

}
