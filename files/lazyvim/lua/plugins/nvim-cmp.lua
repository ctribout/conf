return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")
    local updates = {
      completion = {
        keyword_length = 1,
      },
      performance = {
        fetching_timeout = 500,
        max_view_entries = 50,
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "buffer", keyword_length = 5 },
        { name = "path" },
      },
      mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
      }),
      completion = {
        completeopt = "menu,menuone,noinsert,noselect",
      },
      preselect = cmp.PreselectMode.None,
      view = {
        doc = { auto_open = true, }
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
              [types.lsp.CompletionItemKind.Variable] = 1,
              [types.lsp.CompletionItemKind.Method] = 2,
              [types.lsp.CompletionItemKind.Property] = 3,
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
      formatting = {
        format = function(entry, item)
          local icons = require("lazyvim.config").icons.kinds
          if icons[item.kind] then
            item.kind = icons[item.kind] .. item.kind
          end
          item.menu = ({
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            luasnip = "[LuaSnip]",
            nvim_lua = "[Lua]",
            latex_symbols = "[LaTeX]",
          })[entry.source.name]
          return item
        end,
      },
    }
    return vim.tbl_deep_extend("force", opts, updates)
  end,
}
