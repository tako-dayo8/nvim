-- プラグイン: GitのURLを並べるだけ。起動時に未インストールなら取得される
vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.*') },
  'https://github.com/windwp/nvim-autopairs',
  'https://github.com/folke/tokyonight.nvim',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/refractalize/oil-git-status.nvim',
  'https://github.com/nvim-lua/plenary.nvim',          -- Telescope が内部で使う部品集
  'https://github.com/nvim-telescope/telescope.nvim',  -- 検索画面の本体
  'https://github.com/folke/flash.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',  
  'https://github.com/sindrets/diffview.nvim',
})

require('ai')

require('blink.cmp').setup({
	keymap = {
		preset = 'enter',
		['<Tab>'] = { 'select_next', 'fallback' },
		['<S-Tab>'] = { 'select_prev', 'fallback' },
	},
	completion = {
		-- 自分で選ぶまで候補を選択状態にしない(勝手に Enter で確定されないように)
    	list = { selection = { preselect = false } },
    	-- 候補を選ぶと横にドキュメントを出す
		documentation = { auto_show = true },
    	-- メニューに枠線を付ける
    	menu = { border = 'rounded' },
	},
	 -- 関数の引数を入力中に、引数の説明を出す
  	signature = { enabled = true },


	-- コマンドラインサジェスト
	cmdline = {
		enabled = true,
		keymap = {
			['<Tab>'] = { 'select_next', 'fallback' },
			['<S-Tab>'] = { 'select_prev', 'fallback' },
		},
		completion = {
			list = { selection = { preselect = false }},
			menu = {
				auto_show = function()
					return vim.fn.getcmdtype() == ':'
				end,
			}
		},
	}
})

-- Neovim 内蔵のファイル一覧(netrw)を無効にする
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('nvim-web-devicons').setup()

-- 既定の設定でツリーを有効にする
require("oil").setup({
	win_options = {
		signcolumn = 'yes:2',
	}
})

require("oil-git-status").setup()

-- ノーマルモードで Space → e を押すと、ツリーを開閉する
vim.keymap.set('n', '<Space>t', '<Cmd>Oil<CR>')

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

local capabilities = vim.lsp.protocol.make_client_capabilities()
vim.lsp.config('markdown-oxide', {
	 capabilities = vim.tbl_deep_extend(
        'force',
        capabilities,
        {
            workspace = {
                didChangeWatchedFiles = {
                    dynamicRegistration = true,
                },
            },
        }
    ),
})

-- LSP: 使うサーバーを有効化。名前は nvim-lspconfig 内の設定名と対応している
-- 対応するファイル(.go など)を開いたときに、自動でサーバーが起動する
vim.lsp.enable({ 'lua_ls', 'ts_ls', 'gopls','pylsp', 'ruff', 'bashls', 'markdown-oxide' })

-- エラーや警告を行の右側に表示する(既定では非表示)
vim.diagnostic.config({ virtual_text = true })


vim.cmd.colorscheme('tokyonight')

vim.o.tabstop = 4     -- タブ文字1個を4桁幅で表示する
vim.o.shiftwidth = 4  -- 自動インデントや >> で動く幅

vim.opt.number = true
vim.opt.relativenumber = true


local npairs = require('nvim-autopairs')
npairs.setup()

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


-- flash.nvim 
local flash = require("flash")
flash.setup({
	label = {
		before = true,
		after = false,
	}
})
vim.keymap.set({'n', 'x', 'o'}, '<CR>', function()
	flash.jump()
end, { desc = "Flash Jump" })

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

