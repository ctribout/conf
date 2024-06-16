local utils = require("utils")

return {

  -- Python virtualenv selector
  {
    -- https://github.com/linux-cultist/venv-selector.nvim"
    "linux-cultist/venv-selector.nvim",
    -- The latest version on main now annoyingly nags about switching to another version
    -- at each startup, so stay away from it until an actual switch to that "regexp"
    -- branch
    tag = "0.4",
    lazy = true,
    cmd = "VenvSelect",
    opts = {
      name = { "venv", ".venv", "env", ".env", ".pyenv", "pyenv" },
      notify_user_on_activate = false,
    },
    keys = {
      { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select VirtualEnv" },
      {
        "<leader>cV",
        function()
          local venv = utils.find_venv()
          if venv then
            require('venv-selector.venv').set_venv_and_system_paths({ value = venv })
          else
            vim.print("No VirtualEnv found")
          end
        end,
        desc = "Auto set VirtualEnv (current file)",
      },
    },
  },

}
