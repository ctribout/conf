return {

  -- Treesitter parser generator for faster and more accurate syntax highlighting
  {
    -- https://github.com/nvim-treesitter/nvim-treesitter
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts_extend = { "ensure_installed" },
    ---@alias lazyvim.TSFeat { enable?: boolean, disable?: string[] }
    ---@class lazyvim.TSConfig: TSConfig
    opts = {
      indent = { enable = true }, ---@type lazyvim.TSFeat
      highlight = { enable = true }, ---@type lazyvim.TSFeat
      ensure_installed = {
        -- c, lua, query, vimdoc and vim are mandatory (as nvim ships them too and it
        -- can conflict)
        "bash",
        "c",
        "diff",
        "dockerfile",
        "gitcommit",
        "git_config",
        "git_rebase",
        "gitcommit",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "make",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "rst",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
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
    ---@param opts TSConfig
    config = function(plugin, opts)
      require("nvim-treesitter").setup(opts)
    end,
  },

  -- Textobjects for treesitter
  {
    -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
  },

  -- Show context of the current function
  {
    -- https://github.com/nvim-treesitter/nvim-treesitter-context
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      mode = "cursor",
      max_lines = 4,
      trim_scope = 'inner',  -- or 'outer'
      line_numbers = true,
    },
  },

}

