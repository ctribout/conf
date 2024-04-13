return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      virtual_text = false,
      update_in_insert = false,
      underline = false,
      float = {
        border = "single",
        source = true,
        suffix = "",
      },
    },
    servers = {
      -- see possible servers and conf at
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
      pyright = {
        -- https://github.com/microsoft/pyright/blob/main/packages/vscode-pyright/package.json
        settings = {
          python = {
            analysis = {
              -- disable auto completion entries that propose random content
              -- with the need for an extra imports added at the same time
              autoImportCompletions = false,
              ignore = { '*' }, -- Ruff used instead
              typeCheckingMode = 'on', -- Mypy used instead
            },
          },
        },
      },
      ruff_lsp = {
        init_options = {
         -- https://github.com/astral-sh/ruff-lsp
          settings = {
            fixAll = false,
            lint = {
              args = { -- TODO: maybe move that to ~/.config/ruff/ruff.toml ?
                -- rules: https://docs.astral.sh/ruff/rules/
                "--select=E,W", -- pycodestyle
                "--select=I", -- isort
                "--select=F", -- pyflakes
                "--select=D,ANN", -- pydocstyle and flake8-annotations (doc)
                "--select=N", -- pep8-naming
                "--select=C4", -- flake8-comprehensions
                "--select=UP", -- pyupgrade (deprecated syntax/usage)
                "--select=S", -- bandit (security)
                "--select=B", -- bugbear (misc lints)
                "--select=A", -- flake8-builtins (shadowing builtins)
                "--select=T10", -- flake8-debugger
                "--select=EXE", -- flake8-executable
                "--select=ISC", -- flake8-implicit-str-concat
                "--select=PIE", -- flake8-pie (misc lints)
                "--select=RET", -- flake8-return (simpler return usage)
                "--select=SIM", -- flake8-simplify (use simpler syntax) 
                "--select=SLF", -- flake8-self (private attribute access) 
                "--select=PTH", -- flake8-use-pathlib
                "--select=PL",  -- pylint
                "--select=RUF", -- ruff extra lints
                -- extra configuration
                "--config", "pydocstyle.convention = 'google'",
                -- disable pylint "too few" or "too many" arbitrary checks
                "--ignore=PLR0904,PLR0911,PLR0912,PLR0913,PLR0914,PLR0915,PLR0916,PLR0917,PLR1702",
                -- disable missing-type-self (annotations for "self" parameters, deprecated)
                "--ignore=ANN101"
              }
           },
          },
        },
      },
    },
  },
}
