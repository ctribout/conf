local function find_project_dir(paths)
  paths = paths or { ".git", ".svn", ".hg", "pyproject.toml", "requirements.txt" }
  local found = vim.fs.find(
    paths,
    { upward = true, stop = vim.loop.os_homedir(), path = vim.fs.dirname(vim.fn.expand("%:p")) }
  )
  if #found == 0 then
    return vim.loop.os_homedir()
  end
  local project_dir = vim.fs.dirname(found[1])
  if not project_dir or project_dir == "." or project_dir == "" or project_dir == " " then
    project_dir = string.match(vim.fn.execute("pwd"), "^%s*(.-)%s*$")
  end
  if not project_dir or project_dir == "." or project_dir == "" or project_dir == " " then
    return nil
  end
  return project_dir
end

local function find_venv()

  local curdir = vim.fs.dirname(vim.fn.expand("%:p"))
  -- Check using poetry
  if vim.fn.executable('poetry') == 1 then
    local poetry_root_dir = find_project_dir({ "poetry.lock" })
    if poetry_root_dir then
      local folder = vim.fn.systemlist({'poetry', '-C', curdir, 'env', 'info', '--path' })[1]
      if vim.api.nvim_get_vvar("shell_error") == 0 then
        if vim.fn.isdirectory(folder) == 1 then
          return vim.fn.expand(folder)
        end
      end
    end
  end
  -- Fallback: find a folder with a venv "usual" name
  local found = vim.fs.find(
    { ".venv", ".env", "venv", "env", "pyenv", ".pyenv" },
    { upward = true, type = 'directory', stop = find_project_dir(), path = curdir }
  )
  if #found > 0 then
    return found[1]
  end
end


function icon(sign, len)
  sign = sign or {}
  len = len or 2
  local text = vim.fn.strcharpart(sign.text or "", 0, len)
  text = text .. string.rep(" ", len - vim.fn.strchars(text))
  return sign.texthl and ("%#" .. sign.texthl .. "#" .. text .. "%*") or text
end

function get_mark(buf, lnum)
  local marks = vim.fn.getmarklist(buf)
  vim.list_extend(marks, vim.fn.getmarklist())
  for _, mark in ipairs(marks) do
    if mark.pos[1] == buf and mark.pos[2] == lnum and mark.mark:match("[a-zA-Z]") then
      return { text = mark.mark:sub(2), texthl = "DiagnosticHint" }
    end
  end
end

function get_signs(buf, lnum)
  -- Get regular signs
  local signs = {}

  if vim.fn.has("nvim-0.10") == 0 then
    -- Only needed for Neovim <0.10
    -- Newer versions include legacy signs in nvim_buf_get_extmarks
    for _, sign in ipairs(vim.fn.sign_getplaced(buf, { group = "*", lnum = lnum })[1].signs) do
      local ret = vim.fn.sign_getdefined(sign.name)[1]
      if ret then
        ret.priority = sign.priority
        signs[#signs + 1] = ret
      end
    end
  end

  -- Get extmark signs
  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = "sign" }
  )
  for _, extmark in pairs(extmarks) do
    signs[#signs + 1] = {
      name = extmark[4].sign_hl_group or "",
      text = extmark[4].sign_text,
      texthl = extmark[4].sign_hl_group,
      priority = extmark[4].priority,
    }
  end

  -- Sort by priority
  table.sort(signs, function(a, b)
    return (a.priority or 0) < (b.priority or 0)
  end)

  return signs
end

function statuscolumn()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  local is_file = vim.bo[buf].buftype == ""
  local show_signs = vim.wo[win].signcolumn ~= "no"

  local components = { "", "", "" } -- left, middle, right

  if show_signs then
    ---@type Sign?,Sign?,Sign?
    local left, right, fold
    for _, s in ipairs(get_signs(buf, vim.v.lnum)) do
      if s.name and (s.name:find("GitSign") or s.name:find("MiniDiffSign")) then
        right = s
      else
        left = s
      end
    end
    if vim.v.virtnum ~= 0 then
      left = nil
    end
    vim.api.nvim_win_call(win, function()
      if vim.fn.foldclosed(vim.v.lnum) >= 0 then
        fold = { text = vim.opt.fillchars:get().foldclose or "", texthl = "Folded" }
      end
    end)
    -- Left: mark or non-git sign
    components[1] = icon(get_mark(buf, vim.v.lnum) or left)
    -- Right: fold icon or git sign (only if file)
    components[3] = is_file and icon(fold or right) or ""
  end

  -- Numbers in Neovim are weird
  -- They show when either number or relativenumber is true
  local is_num = vim.wo[win].number
  local is_relnum = vim.wo[win].relativenumber
  if (is_num or is_relnum) and vim.v.virtnum == 0 then
    if vim.v.relnum == 0 then
      components[2] = is_num and "%l" or "%r" -- the current line
    else
      components[2] = is_relnum and "%r" or "%l" -- other lines
    end
    components[2] = "%=" .. components[2] .. " " -- right align
  end

  if vim.v.virtnum ~= 0 then
    components[2] = "%= "
  end

  return table.concat(components, "")
end

icons = {
  diagnostics = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
  },
  git = {
    added = " ",
    modified = " ",
    removed = " ",
  },
  kinds = {
    Array = " ",
    Boolean = " ",
    Class = " ",
    Color = " ",
    Constant = " ",
    Constructor = " ",
    Copilot = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = " ",
    Interface = " ",
    Key = " ",
    Keyword = " ",
    Method = " ",
    Module = " ",
    Namespace = " ",
    Null = " ",
    Number = " ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = " ",
    String = " ",
    Struct = " ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = " ",
  },
}

return {
  find_project_dir = find_project_dir,
  find_venv = find_venv,
  statuscolumn = statuscolumn,
  icons = icons,
}
