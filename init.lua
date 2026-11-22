-- プラグイン管理 (lazy.nvim)
require('plugins')

-- ファイルを開いたとき、.git 等があるプロジェクトルートへ自動で移動する
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    local root = vim.fs.root(args.buf, { ".git", "package.json", "go.mod", "pyproject.toml" })
    if root then
      vim.fn.chdir(root)
    end
  end,
})

require('ai')
require('inline-terminal')
require('lsp')


require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
  views = {
    cmdline_popup = {
      position = {
        row = "85%", -- 下側に配置（微調整したい場合は "90%" などに変更）
        col = "50%",
      },
      size = {
        width = 60,
        height = "auto",
      },
    },
  },
  messages = {
    enabled = true,
    view = "notify",       -- 通常のコマンド結果（:w, :echo 等）
    view_error = "notify", -- エラー
    view_warn = "notify",  -- 警告
  },
})


require("snacks").setup({
  dashboard = {
    enabled = true,
    sections = {
      { section = "header" },
      { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
      { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
      { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
    },
  },
  notifier = {
    enabled = true,
    timeout = 3000, -- 表示時間（ミリ秒）
  },
})

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

local telescope = require('telescope')
local builtin = require('telescope.builtin')

telescope.setup({
  defaults = {
    -- .git と node_modules を検索から除外
    file_ignore_patterns = {
      '%.git[/\\]',
      'node_modules[/\\]',
    },
  },
  extensions = {
  frecency = {
    -- 削除済みファイルを自動で履歴から掃除する
    auto_validate = true,
    -- 検索窓で :CWD: のようにタグ絞り込みを使える
    default_workspace = "CWD",
  },
}
})

-- 拡張機能を読み込み
telescope.load_extension('live_grep_args')
telescope.load_extension("frecency")

-- 例1: 現在のプロジェクト(CWD)内のよく使うファイルだけから探す
vim.keymap.set("n", "<Space>r", "<Cmd>Telescope frecency workspace=CWD<CR>")

-- Space → f: ファイル名で探して開く
vim.keymap.set('n', '<Space>f', builtin.find_files)
-- Space → s: プロジェクト全体から文字列を探す（-g *.ts 等で絞り込み可能）
vim.keymap.set('n', '<Space>s', telescope.extensions.live_grep_args.live_grep_args)
-- Space → b: 今開いているファイル(バッファ)の一覧から選ぶ
vim.keymap.set('n', '<Space>b', builtin.buffers)

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
  -- ★ tabnew の前に、元のバッファからディレクトリを取得する
  local dir
  if vim.bo.filetype == 'oil' then
    dir = require('oil').get_current_dir()
  else
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname ~= '' then
      if vim.fn.isdirectory(bufname) == 1 then
        dir = bufname
      else
        dir = vim.fn.fnamemodify(bufname, ':p:h')
      end
    end
  end
  if not dir or dir == '' or vim.fn.isdirectory(dir) ~= 1 then
    dir = vim.fn.getcwd()
  end

  vim.cmd('tabnew')
  local tab = vim.api.nvim_get_current_tabpage()
  local buf = vim.api.nvim_get_current_buf()

  -- 今のバッファをターミナルにして、lazygit を起動する
  vim.fn.jobstart('lazygit', {
    cwd = dir, -- ★ ここを追加
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


require("glance").setup({
  height = 18,
  border = {
    enable = true,
    top_char = "―",
    bottom_char = "―",
  },
  list = {
    position = "right",
    width = 0.33,
  },
  theme = {
    enable = true,
    mode = "darken",
  },
})

-- 3. キーマップ（LSPの参照・定義などをインライン展開）
local map = vim.keymap.set
map("n", "gr", "<CMD>Glance references<CR>", { desc = "Glance References" })
map("n", "gd", "<CMD>Glance definitions<CR>", { desc = "Glance Definitions" })
map("n", "gt", "<CMD>Glance type_definitions<CR>", { desc = "Glance Type Definitions" })
map("n", "gM", "<CMD>Glance implementations<CR>", { desc = "Glance Implementations" })
