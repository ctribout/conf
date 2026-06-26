local utils = require("utils")

return {

  -- auto completion
  {
    "saghen/blink.cmp",
    version = "1.*", -- release tag ships a prebuilt fuzzy binary, no cargo needed
    event = "InsertEnter",
    ---@module "blink.cmp"
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "none",
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-Space>"] = { "show", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
        ["<CR>"] = { "accept", "fallback" }, -- only confirms an explicitly selected item
        ["<S-CR>"] = { "select_and_accept", "fallback" }, -- select first if none, then accept
      },
      appearance = {
        kind_icons = utils.icons.kinds,
        nerd_font_variant = "mono",
      },
      signature = { enabled = true },
      completion = {
        list = {
          selection = {
            preselect = false, -- nothing auto-selected, so <CR> stays a newline until you pick
            auto_insert = true, -- moving the selection inserts its text (old SelectBehavior.Insert)
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        menu = {
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
            components = {
              source_name = {
                text = function(ctx)
                  return ({
                    LSP = "[LSP]",
                    Buffer = "[BUF]",
                    Path = "[PATH]",
                  })[ctx.source_name] or ("[" .. ctx.source_name .. "]")
                end,
              },
            },
          },
        },
      },
      sources = {
        default = { "lsp", "path", "buffer" },
        providers = {
          buffer = { min_keyword_length = 5 },
        },
      },
      fuzzy = {
        sorts = {
          -- proposed function parameters (label ending in "=") shown first
          function(a, b)
            local a_param = a.label:sub(-1) == "="
            local b_param = b.label:sub(-1) == "="
            if a_param ~= b_param then
              return a_param
            end
          end,
          -- underscore-prefixed entries last (dunder vars in Python)
          function(a, b)
            local a_under = a.label:sub(1, 1) == "_"
            local b_under = b.label:sub(1, 1) == "_"
            if a_under ~= b_under then
              return b_under
            end
          end,
          -- by kind: the values below force the order (smaller wins), then the default
          -- LSP CompletionItemKind values are used (+ 1000, so they sort after these but
          -- keep their original order)
          function(a, b)
            local modified_priority = {
              [20] = 1, -- EnumMember
              [6] = 2, -- Variable
              [21] = 3, -- Constant
              [2] = 4, -- Method
              [10] = 5, -- Property
              [9] = 6, -- Module
              [14] = 7, -- Keyword
              [1] = 9999, -- Text
            }
            local ka = modified_priority[a.kind] or (1000 + (a.kind or 0))
            local kb = modified_priority[b.kind] or (1000 + (b.kind or 0))
            if ka ~= kb then
              return ka < kb
            end
          end,
          "score",
          "sort_text",
        },
      },
    },
  },

}
