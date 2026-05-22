-- =========================
-- 基本設定
-- =========================
vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"

-- =========================
-- lazy.nvim 読み込み
-- =========================
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")
require("lazy").setup({
  -- lsp
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      -- LspAttachをここで登録（確実にプラグイン読み込み後）
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
          end
        end,
      })

      vim.lsp.config('pyright', {
        capabilities = require('cmp_nvim_lsp').default_capabilities()
      })
      vim.lsp.enable('pyright')
    end
  },

  -- lazy.nvimに追加
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",  -- LSPソース
      "hrsh7th/cmp-buffer",    -- バッファ内の単語
      "hrsh7th/cmp-path",      -- ファイルパス
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<Tab>']   = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<CR>']    = cmp.mapping.confirm({ select = true }),
          ['<C-Space>'] = cmp.mapping.complete(), -- 手動トリガー
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end
  },

  -- ファイルツリー
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        filters = { dotfiles = false, git_ignored = false },
      })
    end
  },
  -- Git差分
  {
    "lewis6991/gitsigns.nvim",
    config = function() require("gitsigns").setup() end
  },
  -- 検索
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function() require('telescope').setup() end
  },
  -- カラースキーム
  {
    "catppuccin/nvim",
    config = function() require('catppuccin').setup() end
  },
  -- autopairs
  {
    "windwp/nvim-autopairs",
    config = function() require('nvim-autopairs').setup() end
  },
  -- MarkdownPreview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    config = function() vim.fn["mkdp#util#install"]() end,
  },
})

-- =========================
-- キーバインド
-- =========================
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>m", ":MarkdownPreview<CR>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-f>", ":Telescope find_files<CR>")
vim.keymap.set("n", "<C-g>", ":Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>g", function()
  vim.cmd("terminal lazygit")
end)

vim.cmd.colorscheme("catppuccin-nvim")
