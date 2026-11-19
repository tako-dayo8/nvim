local state = {
  floating = {
    buf = -1,
    win = -1,
    cwd = nil,
  }
}

-- OSに応じたシェルコマンドを返す関数
local function get_shell_cmd()
  if vim.fn.has("win32") == 1 then
    -- Windowsの場合：pwshがあればpwsh、なければ従来のpowershell
    if vim.fn.executable("pwsh") == 1 then
      return { "pwsh", "-NoLogo" }
    else
      return { "powershell", "-NoLogo" }
    end
  else
    -- Ubuntu (Linux) / macOS の場合：bash（なければデフォルトのvim.o.shell）
    if vim.fn.executable("bash") == 1 then
      return { "bash" }
    else
      return vim.o.shell
    end
  end
end

-- 今開いているファイルのディレクトリを取得（なければカレントディレクトリ）
local function get_target_dir()
  local buf_name = vim.api.nvim_buf_get_name(0)
  buf_name = buf_name:gsub("^oil://", "")

  if buf_name ~= "" and vim.fn.filereadable(buf_name) == 1 then
    return vim.fn.fnamemodify(buf_name, ":p:h")
  elseif buf_name ~= "" and vim.fn.isdirectory(buf_name) == 1 then
    return vim.fn.fnamemodify(buf_name, ":p")
  end

  return vim.fn.getcwd()
end

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, win_config)

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_hide(win)
  end, { buffer = buf, silent = true, desc = "Hide floating terminal" })

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_hide(win)
  end, { buffer = buf, silent = true, desc = "Hide floating terminal" })

  vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { buffer = buf, silent = true, desc = "Exit terminal mode" })

  return { buf = buf, win = win }
end

local toggle_terminal = function()
  local target_dir = get_target_dir()

  if not vim.api.nvim_win_is_valid(state.floating.win) then
    local win_info = create_floating_window({ buf = state.floating.buf })
    state.floating.buf = win_info.buf
    state.floating.win = win_info.win

    if vim.bo[state.floating.buf].buftype ~= "terminal" then
      -- OSごとに判定したシェルで起動
      vim.fn.jobstart(get_shell_cmd(), {
        cwd = target_dir,
        term = true,
      })
      state.floating.cwd = target_dir
    elseif state.floating.cwd ~= target_dir then
      -- ディレクトリが変わっていたら自動で cd（Windows/Linux両対応）
      local chan_id = vim.bo[state.floating.buf].channel
      local cd_cmd = vim.fn.has("win32") == 1
        and ('cd "' .. target_dir .. '"\n')
        or ("cd " .. vim.fn.shellescape(target_dir) .. "\n")
      vim.api.nvim_chan_send(chan_id, cd_cmd)
      state.floating.cwd = target_dir
    end

    vim.cmd.startinsert()
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})
vim.keymap.set({ "n", "t" }, "<C-t>", toggle_terminal, { desc = "Toggle floating terminal" })
