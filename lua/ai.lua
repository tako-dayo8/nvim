-- 外部(AIエージェント等)でファイルが編集されたら自動で再読み込みする
vim.o.autoread = true
vim.o.updatetime = 300
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd('checktime')
    end
  end,
})

-- gitsigns.nvim: 行ごとの変更表示とハンク操作
require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = require('gitsigns')
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- ]c / [c: 次・前の変更箇所(ハンク)へ移動
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({ ']c', bang = true })
      else
        gs.nav_hunk('next')
      end
    end, 'Next git hunk')

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({ '[c', bang = true })
      else
        gs.nav_hunk('prev')
      end
    end, 'Prev git hunk')

    -- Space → h...: ハンクの確認・戻す・ステージ
    map('n', '<Space>hp', gs.preview_hunk, 'Preview hunk')
    map('n', '<Space>hr', gs.reset_hunk, 'Reset hunk')
    map('n', '<Space>hs', gs.stage_hunk, 'Stage hunk')
  end,
})

-- diffview.nvim: 変更ファイル全体の差分ビュー
require('diffview').setup()

-- Space → d: Diffview を開閉する
vim.keymap.set('n', '<Space>d', function()
  if require('diffview.lib').get_current_view() then
    vim.cmd('DiffviewClose')
  else
    vim.cmd('DiffviewOpen')
  end
end, { desc = 'Toggle Diffview' })
