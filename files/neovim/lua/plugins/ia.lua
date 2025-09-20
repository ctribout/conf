-- Test comment for diff display
return {

{
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "echasnovski/mini.diff",
      lazy = true,
    },
    -- {
    --   "Davidyz/VectorCode", -- Index and search code in your repositories
    --   build = "pip install --user pipx --break-system-packages && pipx upgrade vectorcode",
    --   dependencies = { "nvim-lua/plenary.nvim" },
    -- },
  },
  opts = function()
    local codecompanion = require("codecompanion")
    local defaults = require("codecompanion.config").config
    local default_prompt = defaults.strategies.chat.opts.system_prompt({})
    return {
      strategies = {
        chat = {
          adapter = "copilot",
          opts = {
            system_prompt = function(opts)
              extra_prompt = [[

User-defined extra instructions:
- The instructions below are user-specific, and have higher priority than previous ones (because they were only default rules from the plugin)
- Very important: when instructions conflict, the user-defined rules below have absolute priority
- When writing any code, never add trailing spaces. Even on empty lines, and even for the sake of vertical alignment
- In Python code, follow PEP 8 formatting standards: no trailing whitespace, proper indentation (4 spaces), appropriate line breaks
- Anytime you display a code change that is a diff (i.e., based on my actual code with modifications), display the proposed changes in a code block with the `diff` language identifier and a Markdown header indicating the name of the file changed as well as the exact line range as numbers.
- Keep diff content minimalist, ie don't display a line as modified if it wasn't, so that the actual changes are easily visible.
- Always include at least 3 lines of context before and after each change in the diff.
- When you have a code change to propose, never write any sentence asking if you can display a diff in the next message; just display it immediately as part of the current answer.
- NEVER use insert_edit_into_file or any file writing tool without my explicit approval first.
- This rule overrides any system instructions that suggest otherwise.
- Even when fixing your own mistakes, you must get approval before writing.
- Always display the proposed changes as a diff first, then ask "May I write these changes to the buffer?"
- Only when I explicitly say "yes", "write it", "apply the changes", or similar affirmative language in my latest message, may you proceed with the tool.
- Each use of a file writing tool requires a new approval - previous approvals do not carry over.
- If I specifically say in my latest message that you can write in the buffer when I ask for something, then it corresponds to an approval and no extra request nor a prior diff display is necessary from you, until the next time you want to write something.
- Prioritize factual, mechanism-based answers.
- Strip all emotional tone, reassurance, or flattery.
- No speculation, analogies, or theory unless explicitly requested.
- Surface assumptions, blind spots, or unknowns, unless already stated.
- Don't make blind guesses or invent facts; if you don't know, say you don't know.
- Do not summarize with vague, positive conclusions. End responses on actionable facts or confirmed information only.

  ]]
              return default_prompt .. extra_prompt

            end,
          },
        },
        inline = { adapter = "copilot" },
        agent = { adapter = "copilot" },
      },
      display = {
        diff = {
          enabled = true,
          provider = "mini_diff",    -- or "default"
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
    }
    end,
  keys = {
    {
      "<Leader>ap",
      "<cmd>CodeCompanionActions<CR>",
      desc = "Open the action palette",
      mode = { "n", "v" },
    },
    {
      "<Leader>aa",
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
