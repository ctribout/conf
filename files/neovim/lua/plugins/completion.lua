local utils = require("utils")

return {

  -- auto completion
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp-signature-help",
    },
    opts = function()
      local cmp = require("cmp")
      return {
        completion = {
          completeopt = "menu,menuone,noinsert,noselect,fuzzy,preview",
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Don't select the first item automatically
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        preselect = cmp.PreselectMode.None,
        sources = cmp.config.sources({
          { name = "nvim_lsp_signature_help" },
          { name = "nvim_lsp" },
          { name = "buffer", keyword_length = 5 },
          { name = "path" },
        }),
        formatting = {
          format = function(entry, item)
            local icons = utils.icons.kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
            item.menu = ({
              nvim_lsp_signature_help = "[LSP]",
              nvim_lsp = "[SIG]",
              buffer = "[BUF]",
              path = "[PATH]",
              conventionalcommits = "[CC]",
            })[entry.source.name]
            return item
          end,
        },
        experimental = {
          ghost_text = false,
        },
        sorting = {
          comparators = {
            cmp.config.compare.exact,
            -- have the proposed function parameters shown first ("param=")
            function(entry1, entry2)
              local _, entry1_param = entry1.completion_item.label:find "=$"
              local _, entry2_param = entry2.completion_item.label:find "=$"
              entry1_param = entry1_param or 0
              entry2_param = entry2_param or 0
              if entry1_param > entry2_param then
                return true
              elseif entry1_param < entry2_param then
                return false
              end
            end,
            -- copied from cmp-under (underscores at the end, for dunder vars in Python)
            function(entry1, entry2)
              local _, entry1_under = entry1.completion_item.label:find "^_+"
              local _, entry2_under = entry2.completion_item.label:find "^_+"
              entry1_under = entry1_under or 0
              entry2_under = entry2_under or 0
              if entry1_under > entry2_under then
                return false
              elseif entry1_under < entry2_under then
                return true
              end
            end,
            function(entry1, entry2) -- sort by compare kind (Variable, Function etc)
              local types = require("cmp.types")
              local modified_priority = {
                -- see https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/types/lsp.lua
                -- The values defined below force the order (smaller wins), then the default
                -- values are used (+ 1000, so that they are after those defined here, but still
                -- with their original order)
                [types.lsp.CompletionItemKind.EnumMember] = 1,
                [types.lsp.CompletionItemKind.Variable] = 2,
                [types.lsp.CompletionItemKind.Constant] = 3,
                [types.lsp.CompletionItemKind.Method] = 4,
                [types.lsp.CompletionItemKind.Property] = 5,
                [types.lsp.CompletionItemKind.Module] = 6,
                [types.lsp.CompletionItemKind.Keyword] = 7,
                [types.lsp.CompletionItemKind.Text] = 9999,
              }
              local kind1 = entry1:get_kind()
              kind1 = modified_priority[kind1] or 1000 + kind1
              local kind2 = entry2:get_kind()
              kind2 = modified_priority[kind2] or 1000 + kind2
              if kind1 ~= kind2 then
                return kind1 - kind2 < 0
              end
            end,
            -- cmp.config.compare.score,
            -- cmp.config.compare.kind,
            cmp.config.compare.recently_used,
            cmp.config.compare.offset,
            cmp.config.compare.locality,
            cmp.config.compare.sort_text,
            cmp.config.compare.order,
          },
        },
      }
    end,
  },

}
