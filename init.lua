-- プラグイン: GitのURLを並べるだけ。起動時に未インストールなら取得される
vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/windwp/nvim-autopairs',
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons', -- ファイル種別のアイコン
  'https://github.com/nvim-tree/nvim-tree.lua',     -- ファイルツリー本体
  'https://github.com/nvim-lua/plenary.nvim',          -- Telescope が内部で使う部品集
  'https://github.com/nvim-telescope/telescope.nvim',  -- 検索画面の本体
})

-- Neovim 内蔵のファイル一覧(netrw)を無効にする
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 既定の設定でツリーを有効にする
require('nvim-tree').setup()

-- ノーマルモードで Space → e を押すと、ツリーを開閉する
vim.keymap.set('n', '<Space>t', '<Cmd>NvimTreeToggle<CR>')

local builtin = require('telescope.builtin')

-- Space → f: ファイル名で探して開く
vim.keymap.set('n', '<Space>f', builtin.find_files)
-- Space → s: プロジェクト全体から文字列を探す
vim.keymap.set('n', '<Space>s', builtin.live_grep)
-- Space → b: 今開いているファイル(バッファ)の一覧から選ぶ
vim.keymap.set('n', '<Space>b', builtin.buffers)

-- lua_ls: resolve global `vim`
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' }, -- これで警告が消えます
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true), -- これでvim.*の補完が出ます
        checkThirdParty = false,
      },
    },
  },
})


-- LSP: 使うサーバーを有効化。名前は nvim-lspconfig 内の設定名と対応している
-- 対応するファイル(.go など)を開いたときに、自動でサーバーが起動する
vim.lsp.enable({ 'lua_ls', 'gopls','pylsp', 'ruff', 'bashls' })

-- エラーや警告を行の右側に表示する(既定では非表示)
vim.diagnostic.config({ virtual_text = true })

-- 補完: サーバーがバッファに接続された瞬間(LspAttach)に補完を有効化
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    -- 補完に対応しているサーバーのときだけ有効にする
    if client and client:supports_method('textDocument/completion') then
      local chars = {}
      for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})

-- 補完メニューの挙動: 候補が1つでも表示し、勝手に選択しない
vim.opt.completeopt = { 'menuone', 'noselect', 'popup' }
vim.cmd.colorscheme('tokyonight')

vim.o.tabstop = 4     -- タブ文字1個を4桁幅で表示する
vim.o.shiftwidth = 4  -- 自動インデントや >> で動く幅

-- Tab: メニュー表示中は次の候補へ、それ以外は普通のTab
vim.keymap.set('i', '<Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true })

-- Shift-Tab: メニュー表示中は前の候補へ
vim.keymap.set('i', '<S-Tab>', function()
  return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true })

local npairs = require('nvim-autopairs')
-- Enterの割り当ては下で自分で書くので、プラグイン側の割り当ては切る
npairs.setup({ map_cr = false })

vim.keymap.set('i', '<CR>', function()
  if vim.fn.pumvisible() == 1 then
    -- 候補を選択中なら確定
    if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
      return npairs.esc('<C-y>')
    end
    -- メニューは出ているが未選択なら、メニューを閉じてから改行
    return npairs.esc('<C-e>') .. npairs.autopairs_cr()
  end
  -- メニューが出ていなければ、プラグインの改行処理に任せる
  return npairs.autopairs_cr()
end, { expr = true, replace_keycodes = false })



vim.api.nvim_create_autocmd('CompleteDone', {
  callback = function()
    -- Enter(Ctrl-y)で確定したとき以外は何もしない
    if vim.v.event.reason ~= 'accept' then return end

    -- 確定した候補について、言語サーバーが送ってきた元データを取り出す
    local item = vim.tbl_get(vim.v.completed_item, 'user_data', 'nvim', 'lsp', 'completion_item')
    if not item then return end

    -- 関数とメソッド以外(変数、モジュールなど)は対象外
    local kinds = vim.lsp.protocol.CompletionItemKind
    if item.kind ~= kinds.Function and item.kind ~= kinds.Method then return end

    -- サーバー側が括弧付きのスニペットを送ってきた場合は、そちらに任せる
    if item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet then return end

    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    -- すでに括弧があるなら足さない
    if line:sub(col, col) == ')' or line:sub(col + 1, col + 1) == '(' then return end
    -- Python の import 文の中では足さない(from os import getcwd など)
    if line:match('^%s*from%s') or line:match('^%s*import%s') then return end

    -- カーソル位置に () を挿入し、カーソルを1つ右(括弧の間)へ動かす
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { '()' })
    vim.api.nvim_win_set_cursor(0, { row, col + 1 })
  end,
})

-- Space → g: 新しいタブで lazygit を開く
vim.keymap.set('n', '<Space>g', function()
  vim.cmd('tabnew')
  local tab = vim.api.nvim_get_current_tabpage()
  local buf = vim.api.nvim_get_current_buf()

  -- 今のバッファをターミナルにして、lazygit を起動する
  vim.fn.jobstart('lazygit', {
    term = true,
    -- lazygit を終了したら、このバッファ(とタブ)を片付ける
    on_exit = function()
           -- 1. lazygit を開いたタブを閉じる
      if vim.api.nvim_tabpage_is_valid(tab) then
        pcall(vim.cmd, 'tabclose! ' .. vim.api.nvim_tabpage_get_number(tab))
      end
      -- 2. 残ったターミナルのバッファを消す
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
        end,
})
  -- このターミナルの中だけ、Esc を lazygit にそのまま渡す
  vim.keymap.set('t', '<Esc>', '<Esc>', { buffer = buf })
  vim.cmd('startinsert')
end)
