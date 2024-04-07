-- diagnostics from https://github.com/nvim-lualine/lualine.nvim/discussions/911

return {
  {
    "nvim-lualine/lualine.nvim",
    -- Note: tab line managed by the bufferline.nvim pluging instead
    opts = function(_, opts)
      local utils = require("lualine.utils.utils")
      local diagnostics_message = require("lualine.component"):extend()
      function diagnostics_message:update_status(is_focused)
        local r, _ = unpack(vim.api.nvim_win_get_cursor(0))
        local diagnostics = vim.diagnostic.get(0, { lnum = r - 1 })
        if #diagnostics > 0 then
          local top = diagnostics[1]
          for _, d in ipairs(diagnostics) do
            if d.severity < top.severity then
              top = d
            end
          end
          -- lualine_c gets truncated first if too long, but it's the left part
          -- of the string that is lost, which is not convenient: truncate it on
          -- the right already, so that it's hopefully still readable a bit longer
          -- The value reserved for all other elements is empiric and should allow
          -- to have correct behavior in most cases
          local length_max = vim.fn.winwidth(0) - 65
          if length_max <= 0 then
            return ""
          end
          local message = top.message:gsub("\n.*","")
          if #message > length_max then
            message = string.sub(top.message, 1, length_max-3) .. "(…)"
          end
          return utils.stl_escape(message)
        else
          return ""
        end
      end
      return {
        sections = {
          lualine_a = {'mode'},
          lualine_b = {
            --{
            --  'filename',
            --  path = 4,
            --  symbols = {
            --    modified = '',
            --    readonly = '',
            --    newfile = '',
            --    unnamed = '󰋶'
            --  }
            --},
            'branch',
            'diff',
            'diagnostics',
          },
          lualine_c = {
            { diagnostics_message }
          },
          lualine_x = {
            -- 'encoding',
            -- 'fileformat',
            -- 'filetype',
          },
          lualine_y = {
            'selectioncount',
            'searchcount',
            'progress',
          },
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
      }
    end
  },
}
