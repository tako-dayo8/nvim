local conform = require("conform")
local util = require("conform.util")

-- フォーマッターを Mason で自動インストール
local function ensure_mason_packages(packages)
  local ok, mr = pcall(require, "mason-registry")
  if not ok then
    return
  end

  local all_installed = true
  for _, name in ipairs(packages) do
    if not mr.is_installed(name) then
      all_installed = false
      break
    end
  end
  if all_installed then
    return
  end

  mr.refresh(function()
    for _, name in ipairs(packages) do
      local has_pkg, pkg = pcall(mr.get_package, name)
      if has_pkg and not pkg:is_installed() and not pkg:is_installing() then
        pkg:install()
      end
    end
  end)
end

ensure_mason_packages({
  "prettier",
  "biome",
  "ruff",
})

conform.setup({
  formatters_by_ft = {
    javascript = { "biome", "prettier", stop_after_first = true },
    typescript = { "biome", "prettier", stop_after_first = true },
    javascriptreact = { "biome", "prettier", stop_after_first = true },
    typescriptreact = { "biome", "prettier", stop_after_first = true },
    css = { "biome", "prettier", stop_after_first = true },
    json = { "biome", "prettier", stop_after_first = true },
    jsonc = { "biome", "prettier", stop_after_first = true },
    html = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    python = { "ruff_format" },
  },
  formatters = {
    -- Windows の node_modules/.bin/biome.cmd も正しく検出できるようにする
    biome = {
      command = util.find_executable({
        "node_modules/.bin/biome.cmd",
        "node_modules/.bin/biome.exe",
        "node_modules/.bin/biome",
      }, "biome"),
    },
    -- プロジェクトに設定ファイルがない場合のみデフォルト引数を適用する
    prettier = {
      prepend_args = function(self, ctx)
        if self:cwd(ctx) or vim.fs.root(ctx.dirname, { ".editorconfig" }) then
          return {}
        end
        return {
          "--tab-width", "4", -- インデント幅（2 または 4 に変更）
          "--use-tabs", "false", -- true にするとスペースではなくハードタブ(\t)を使用
          "--single-quote", "true", -- シングルクォートに統一（不要なら削除）
          "--print-width", "400",
        }
      end,
    },
  },
})

-- プロジェクトルート + ファイルタイプごとに選択済みフォーマッターを記憶する
local selected_formatters = {}
local home_dir = vim.fs.normalize(vim.uv.os_homedir() or "")

local function get_buf_dir(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local dir = bufname ~= "" and vim.fn.fnamemodify(bufname, ":p:h") or vim.fn.getcwd()
  return vim.fs.normalize(dir)
end

local function is_project_config(info, buf_dir)
  if not info.cwd then
    return false
  end
  local cwd = vim.fs.normalize(info.cwd)
  -- ホーム直下の設定（例: ~/.prettierrc）はプロジェクト固有の設定ファイルとはみなさない
  if home_dir ~= "" and cwd == home_dir and buf_dir ~= home_dir then
    return false
  end
  return true
end

local function get_closest_configured(formatters, buf_dir)
  local closest = {}
  local max_len = -1
  for _, info in ipairs(formatters) do
    if is_project_config(info, buf_dir) then
      local len = #vim.fs.normalize(info.cwd)
      if len > max_len then
        max_len = len
        closest = { info }
      elseif len == max_len then
        table.insert(closest, info)
      end
    end
  end
  return closest
end

local function get_selection_key(bufnr)
  local root = vim.fs.root(bufnr, { ".git", "package.json", "go.mod", "pyproject.toml" })
  if not root then
    root = get_buf_dir(bufnr)
  end
  return vim.fs.normalize(root) .. "::" .. vim.bo[bufnr].filetype
end

local function has_lsp_formatter(bufnr)
  return #vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/formatting" }) > 0
end

local function get_formatter_states(bufnr)
  local buf_dir = get_buf_dir(bufnr)
  local names = conform.list_formatters_for_buffer(bufnr)
  local available = {}
  local missing_with_config = {}
  for _, name in ipairs(names) do
    local info = conform.get_formatter_info(name, bufnr)
    if info.available then
      table.insert(available, info)
    elseif is_project_config(info, buf_dir) then
      table.insert(missing_with_config, info)
    end
  end
  return available, missing_with_config, buf_dir
end

local function run_format(bufnr, range, choice)
  if choice == "lsp" then
    conform.format({ bufnr = bufnr, async = true, formatters = {}, lsp_format = "fallback", range = range })
  elseif choice then
    conform.format({ bufnr = bufnr, async = true, formatters = { choice }, lsp_format = "never", range = range })
  else
    conform.format({ bufnr = bufnr, async = true, lsp_format = "fallback", range = range })
  end
end

local function select_and_format(bufnr, range, opts)
  opts = opts or {}
  local key = get_selection_key(bufnr)
  local current = selected_formatters[key]
  local available, _, buf_dir = get_formatter_states(bufnr)
  available = opts.available or available
  local lsp_ok = has_lsp_formatter(bufnr)

  local items = {}
  for _, info in ipairs(available) do
    local tags = {}
    if is_project_config(info, buf_dir) then
      table.insert(tags, "設定ファイルあり")
    elseif info.cwd then
      table.insert(tags, "ホーム設定あり")
    end
    if current == info.name then
      table.insert(tags, "選択中")
    end
    local label = info.name
    if #tags > 0 then
      label = label .. " (" .. table.concat(tags, ", ") .. ")"
    end
    table.insert(items, { id = info.name, label = label })
  end

  if lsp_ok then
    local label = "lsp" .. (current == "lsp" and " (選択中)" or "")
    table.insert(items, { id = "lsp", label = label })
  end

  if opts.include_auto and current then
    table.insert(items, { id = "__auto__", label = "auto (自動判定に戻す)" })
  end

  if #items == 0 then
    vim.notify("このファイルタイプで利用可能なフォーマッターがありません", vim.log.levels.WARN)
    return
  end

  vim.ui.select(items, {
    prompt = opts.prompt or "フォーマッターを選択:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    if choice.id == "__auto__" then
      selected_formatters[key] = nil
      vim.notify("フォーマッターを自動判定に戻しました", vim.log.levels.INFO)
      return
    end
    selected_formatters[key] = choice.id
    vim.notify("フォーマッター: " .. choice.id, vim.log.levels.INFO)
    run_format(bufnr, range, choice.id)
  end)
end

local function smart_format(bufnr, range)
  local key = get_selection_key(bufnr)
  local available, missing_with_config, buf_dir = get_formatter_states(bufnr)

  -- 1. すでに選択済みのフォーマッターがあればそれを使う
  local remembered = selected_formatters[key]
  if remembered then
    if remembered == "lsp" and has_lsp_formatter(bufnr) then
      run_format(bufnr, range, "lsp")
      return
    end
    for _, info in ipairs(available) do
      if info.name == remembered then
        run_format(bufnr, range, remembered)
        return
      end
    end
    -- 記憶していたフォーマッターが利用不可になっていたらリセット
    selected_formatters[key] = nil
  end

  -- 2. 設定ファイルがあるのに未インストールのフォーマッターがある場合は通知
  if #missing_with_config > 0 then
    local missing_names = vim.tbl_map(function(info)
      return info.name
    end, missing_with_config)
    vim.notify(
      string.format(
        "%s の設定ファイルがありますが未インストールです (:MasonInstall %s 等で導入可能)",
        table.concat(missing_names, ", "),
        missing_names[1]
      ),
      vim.log.levels.WARN
    )
  end

  -- 3. 利用可能なフォーマッターが 0〜1 個ならそのまま実行
  if #available == 0 then
    run_format(bufnr, range, nil)
    return
  end
  if #available == 1 then
    run_format(bufnr, range, available[1].name)
    return
  end

  -- 4. 複数候補がある場合: 最も近い設定ファイルが 1 つに絞れれば自動判定
  local closest = get_closest_configured(available, buf_dir)
  if #closest == 1 then
    run_format(bufnr, range, closest[1].name)
    return
  end

  -- 5. 設定ファイルが両方ある / どちらもない場合は選択 UI を表示
  local reason = #closest > 1
      and "複数の設定ファイルが見つかりました。フォーマッターを選択:"
    or "フォーマッターを選択 (このプロジェクトで記憶):"
  select_and_format(bufnr, range, {
    available = available,
    prompt = reason,
  })
end

local function get_range(bufnr, args)
  if args.count == -1 then
    return nil
  end
  local end_line = vim.api.nvim_buf_get_lines(bufnr, args.line2 - 1, args.line2, true)[1] or ""
  return {
    start = { args.line1, 0 },
    ["end"] = { args.line2, end_line:len() },
  }
end

-- :Format コマンド（自動判定＋曖昧なときだけ選択）
vim.api.nvim_create_user_command("Format", function(args)
  local bufnr = vim.api.nvim_get_current_buf()
  smart_format(bufnr, get_range(bufnr, args))
end, { range = true })

-- :FormatSelect コマンド（いつでも手動でフォーマッターを選択・切替）
vim.api.nvim_create_user_command("FormatSelect", function(args)
  local bufnr = vim.api.nvim_get_current_buf()
  select_and_format(bufnr, get_range(bufnr, args), { include_auto = true })
end, { range = true })

vim.keymap.set("n", "<leader>f", "<cmd>Format<CR>", { desc = "Format buffer" })
vim.keymap.set("v", "<leader>f", ":Format<CR>", { desc = "Format range" })
vim.keymap.set("n", "<leader>F", "<cmd>FormatSelect<CR>", { desc = "Select formatter and format" })
vim.keymap.set("v", "<leader>F", ":FormatSelect<CR>", { desc = "Select formatter and format range" })
