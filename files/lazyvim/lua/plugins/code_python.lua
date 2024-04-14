local utils = require("utils")

return {

  -- Python virtualenv selector
  {
    -- https://github.com/linux-cultist/venv-selector.nvim"
    "linux-cultist/venv-selector.nvim",
    lazy = true,
    cmd = "VenvSelect",
    opts = {
      name = { "venv", ".venv", "env", ".env" },
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
