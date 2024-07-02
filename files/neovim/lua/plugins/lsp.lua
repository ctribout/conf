local utils = require("utils")

return {

  -- Tool to install and manage LSP servers, linters, formatters, ...
  {
    -- https://github.com/williamboman/mason.nvim
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = {
      { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
    },
    opts = {
      ensure_installed = {
        -- packages available here: https://github.com/mason-org/mason-registry/tree/main/packages
        "pyright",
        "ruff-lsp",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },

  -- LSP config
  {
    -- https://github.com/neovim/nvim-lspconfig
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      -- https://github.com/williamboman/mason.nvim
      "williamboman/mason.nvim",
      -- https://github.com/williamboman/mason-lspconfig.nvim
      "williamboman/mason-lspconfig.nvim",
    },
    opts = {
      inlay_hints = {
        enabled = false,
      },
      codelens = {
        enabled = false,
      },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Go to declaration" })
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover" })
          vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename" })
          vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code action" })
          vim.keymap.set('n', '<leader>cf', function()
            vim.lsp.buf.format { async = true }
          end, { buffer = ev.buf, desc = "Code format" })
          vim.keymap.set('n', 'gd', function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, { buffer = ev.buf, desc = "Go to definition" })
          vim.keymap.set('n', 'gr', "<cmd>Telescope lsp_references<cr>", { buffer = ev.buf, desc = "References" })
          vim.keymap.set('n', 'gi', function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, { buffer = ev.buf, desc = "Go to implementation" })
          vim.keymap.set('n', 'gy', function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, { buffer = ev.buf, desc = "Go to type definition" })
          vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature Help" })
          vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature Help" })
        end,
      })

      local diagnostic_goto = function(next, severity)
        local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
        severity = severity and vim.diagnostic.severity[severity] or nil
        return function()
          go({ severity = severity })
        end
      end
      vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
      vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
      vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
      vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
      vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
      vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
      vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

      -- diagnostics
      for name, icon in pairs(utils.icons.diagnostics) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end
      vim.diagnostic.config({
        virtual_text = false,
        update_in_insert = false,
        underline = false,
        float = {
          border = "single",
          source = true,
          suffix = "",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = utils.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = utils.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = utils.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = utils.icons.diagnostics.Info,
          },
        },
      })

      -- LSP servers
      local servers = {
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

                  -- ignored rules

                  "--ignore=PLC0414",  -- useless-import-alias
                  -- Pylint "too few" or "too many" arbitrary checks
                  "--ignore=PLR0904",  -- too-many-public-methods
                  "--ignore=PLR0911",  -- too-many-return-statements
                  "--ignore=PLR0912",  -- too-many-branches
                  "--ignore=PLR0913",  -- too-many-arguments
                  "--ignore=PLR0914",  -- too-many-locals
                  "--ignore=PLR0915",  -- too-many-statements
                  "--ignore=PLR0916",  -- too-many-boolean-expressions
                  "--ignore=PLR0917",  -- too-many-positional
                  "--ignore=PLR1702",  -- too-many-nested-blocks
                  -- ruff can't manage multi-files very well yet, so docstrings checks for
                  -- methods and classes (where inheritance can be involved) are better
                  -- handled by Pylint Ex.: for methods overloaded in a daughter class
                  -- when the prototype does not change, it's better to not have to
                  -- copy/paste the exact same docstring as the parents'
                  "--ignore=D101",  -- undocumented-public-class
                  "--ignore=D102",  -- undocumented-public-method
                  "--ignore=D107",  -- undocumented-public-init
                  -- Magic methods: they are part of Python's object model, and don't need
                  -- a docstring as it's already in the Python official documentation
                  "--ignore=D105",  -- undocumented-magic-method
                  -- Missing type annotations for "self" or "cls" (useless and deprecated)
                  "--ignore=ANN101",  -- missing-type-self
                  "--ignore=ANN102",  -- missing-type-cls
                  -- Asserts are mostly used to help static checkers like mypy, it's not
                  -- an issue to use them, as long as actual exceptions are raised as
                  -- exception
                  "--ignore=S101",  -- assert
                  -- Failing anytime a `random` function is used, assuming it could be
                  -- used for secrets even when it's not
                  "--ignore=S311",  -- suspicious-non-cryptographic-random-usage
                  -- Failing anytime subprocess.run() or equivalent is used
                  "--ignore=S603",  -- subprocess-without-shell-equals-true
                }
              },
            },
          },
        },
      }
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities(),
        opts.capabilities or {}
      )

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})
        require("lspconfig")[server].setup(server_opts)
      end

      -- get all the servers that are available though mason-lspconfig
      local have_mason, mlsp = pcall(require, "mason-lspconfig")
      local all_mslp_servers = {}
      if have_mason then
        all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
      end

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      if have_mason then
        mlsp.setup({ ensure_installed = ensure_installed })
        mlsp.setup_handlers({ setup })
      end
    end,
  },

}
