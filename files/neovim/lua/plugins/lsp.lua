local utils = require("utils")

return {

  -- Tool to install and manage LSP servers, linters, formatters, ...
  {
    -- https://github.com/mason-org/mason.nvim
    "mason-org/mason.nvim",
    cmd = "Mason",
    event = { "BufReadPre", "BufNewFile", "BufWritePre" },
    keys = {
      { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" },
    },
    opts = {
      ensure_installed = {
        -- packages available here: https://github.com/mason-org/mason-registry/tree/main/packages
        "pyright",
        "ruff",
        "yaml-language-server",
        "bash-language-server",
        "marksman",
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
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
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
        end,
      })

      local diagnostic_goto = function(next, severity)
        severity = severity and vim.diagnostic.severity[severity] or nil
        return function()
          vim.diagnostic.jump({ count = next and 1 or -1, severity = severity })
        end
      end
      vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
      vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
      vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
      vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
      vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
      vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
      vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

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
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
        pyright = {
          -- https://github.com/microsoft/pyright/blob/main/packages/vscode-pyright/package.json
          handlers = {
            ["textDocument/publishDiagnostics"] = function() end,
          },
          settings = {
            python = {
              analysis = {
                -- disable auto completion entries that propose random content
                -- with the need for an extra imports added at the same time
                autoImportCompletions = false,
                ignore = { '*' }, -- Ruff used instead
                typeCheckingMode = 'off', -- Mypy used instead
                -- Disable all diagnostic rules
                diagnosticMode = 'off',
              },
            },
          },
          cmd = { "pyright-langserver", "--stdio" },
          filetypes = { "python" },
        },
        ruff = {
          cmd = { "ruff", "server" },
          filetypes = { "python" },
        },
        yamlls = {
          cmd = { "yaml-language-server", "--stdio" },
          filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
          root_markers = { ".git" },
          settings = {
            yaml = {
              customTags = { "!reference sequence" },
              schemas = {
                ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = {
                  ".gitlab-ci.yml",
                },
              },
            },
          },
        },
        bashls = {
          cmd = { "bash-language-server", "start" },
          filetypes = { "bash", "sh" },
          root_markers = { ".git" },
        },
        marksman = {
          cmd = { "marksman", "server" },
          filetypes = { "markdown", "markdown.mdx" },
          root_markers = { ".marksman.toml", ".git" },
        },
      }

      -- Setup capabilities
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Setup each server
      for server_name, config in pairs(servers) do
        config = config or {}
        config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
        vim.lsp.config[server_name] = config
        vim.lsp.enable(server_name)
      end
    end,
  },

}
