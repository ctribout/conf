return {

{
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- {
    --   "echasnovski/mini.diff",
    --   lazy = true,
    -- },
    -- {
    --   "Davidyz/VectorCode", -- Index and search code in your repositories
    --   build = "pip install --user pipx --break-system-packages && pipx upgrade vectorcode",
    --   dependencies = { "nvim-lua/plenary.nvim" },
    -- },
  },
  opts = {
    strategies = {
      chat = { adapter = "copilot" },
      inline = { adapter = "copilot" },
      agent = { adapter = "copilot" },
    },
    display = {
      diff = {
        enabled = true,
        provider = "default",    -- or "default"
        layout = "vertical",       -- or "horizontal"
      },
    },
    extensions = {
      -- vectorcode = {
      --   opts = {
      --     add_tool = true,
      --   },
      -- },
    },
  },
  keys = {
    {
      "<C-a>",
      "<cmd>CodeCompanionActions<CR>",
      desc = "Open the action palette",
      mode = { "n", "v" },
    },
    {
      "<Leader>a",
      "<cmd>CodeCompanionChat Toggle<CR>",
      desc = "Toggle a chat buffer",
      mode = { "n", "v" },
    },
    {
      "<LocalLeader>a",
      "<cmd>CodeCompanionChat Add<CR>",
      desc = "Add code to a chat buffer",
      mode = { "v" },
    },
  },
},

{
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "BufReadPost",
  opts = {
    suggestion = {
      enabled = false,
      auto_trigger = true,
      hide_during_completion = true,
      keymap = {
        accept = false, -- handled by nvim-cmp / blink.cmp
        next = "<M-]>",
        prev = "<M-[>",
      },
    },
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
},

{
  "zbirenbaum/copilot-cmp",
  opts = {},
  config = function(_, opts)
    local copilot_cmp = require("copilot_cmp")
    copilot_cmp.setup(opts)
  end,
  specs = {
    {
      "hrsh7th/nvim-cmp",
      optional = true,
      ---@param opts cmp.ConfigSchema
      opts = function(_, opts)
        table.insert(opts.sources, 1, {
          name = "copilot",
          group_index = 1,
          priority = 100,
        })
      end,
    },
  },
},

}
