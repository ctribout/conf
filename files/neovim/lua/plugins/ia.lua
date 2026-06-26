-- Test comment for diff display
return {

{
  -- https://github.com/olimorris/codecompanion.nvim
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {"nvim-treesitter/nvim-treesitter", branch = "main"},
  },
  opts = function()
    return {
      interactions = {
        cli = {
          agent = "claude_code",
          agents = {
            claude_code = {
              cmd = "claude",
              args = {},
              description = "Claude Code CLI",
              provider = "terminal",
            },
          },
        },
        chat = {
          adapter = "copilot",
          opts = {
            system_prompt = function(ctx)
              return string.format([[
You are CodeCompanion, an AI coding assistant inside Neovim.
Current date: %s. Neovim: %s. OS: %s (use system-specific commands)

## Behavior
- Respond in %s
- Answer only what is asked. Be concise and factual
- No flattery, reassurance, or emotional tone
- No speculation unless explicitly requested
- State unknowns and assumptions explicitly
- Do not summarize with vague, positive conclusions. End responses on actionable facts
  or confirmed information only

## Task execution
- Think step-by-step and, unless the user requests otherwise or the task is very simple,
  describe your plan in pseudocode
- Do not autonomously run shell commands to discover or read files. Instead, ask the
  user to provide the relevant file or content directly
- Only run shell commands when explicitly asked to, or when the task cannot be completed
  otherwise
- Batch incidental fixes (typos, alignment) into the next planned edit, never as
  standalone actions
- Do not write to any file without explicit user approval ("yes", "write it", "apply")
- Each write action requires fresh approval; prior approvals do not carry over

## Output
- Return code first. Explanation after, only if non-obvious
- No inline prose. Use comments sparingly, only where logic is unclear
- No boilerplate unless explicitly requested
- Use Markdown code blocks with 4 backticks and language ID
- Add `-- filepath: /path/to/file` comment when location is known
- No trailing spaces anywhere, including empty lines
- No H1/H2 headers in responses

## Code Rules
- Simplest working solution. No over-engineering
- No abstractions for single-use operations
- Three similar lines is better than a premature abstraction
- Python: PEP 8 strictly (4-space indent, no trailing whitespace)

## Debugging Rules
- Never speculate about a bug without reading the relevant code first
- State what you found, where, and the fix. One pass
- If cause is unclear: say so. Do not guess

## Simple Formatting
- No em dashes, smart quotes, or decorative Unicode symbols
- Plain hyphens and straight quotes only
- Natural language characters (accented letters, CJK, etc.) are fine when the content
  requires them
- Code output must be copy-paste safe

]],
              ctx.date,
              ctx.nvim_version,
              ctx.os,
              ctx.language
            )
            end,
          },
        },
        inline = { adapter = "copilot" },
        agent = { adapter = "copilot" },
      },
      display = {
        chat = {
          show_context = true,
          show_token_count = true,
          show_tools_processing = true,
          -- show_settings = true,  -- Can't change the adapter if set
        },
        diff = {
          enabled = true,
          threshold_for_chat = 0,
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
      "<Leader>ac",
      "<cmd>CodeCompanionCLI<CR>",
      desc = "Toggle a CLI buffer",
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
  -- https://github.com/zbirenbaum/copilot.lua
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "BufReadPost",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      hide_during_completion = true, -- yield to the blink menu when it's open
      keymap = {
        accept = "<C-l>",
        dismiss = "<C-]>",
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
  config = function(_, opts)
    require("copilot").setup(opts)
    -- ghost text defaults to the Comment color/style, indistinguishable from a
    -- comment you're typing; give it a lighter fg over a slightly raised background
    local palette = require("catppuccin.palettes").get_palette()
    vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = palette.text, bg = palette.surface2 })
  end,
},

}
