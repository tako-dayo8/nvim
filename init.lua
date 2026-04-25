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

  -- ファイルツリー
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        filters = {
          dotfiles = false,
          git_ignored = false,
        },
      })
    end
  },

  -- Git差分
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end
  },

  -- LSP (0.11以降の書き方に最適化)
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Neovim 0.11+ の新しい設定方法
      local servers = {
        ts_ls = {
          filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }
        },
        pyright = {},
        gopls = {}
      }

      for server, config in pairs(servers) do
        -- 新しいAPIがある場合はそちらを使用
        if vim.lsp.config then
          vim.lsp.config(server, config)
          vim.lsp.enable(server)
        else
          -- 万が一古いバージョンに戻した場合の互換性
          require("lspconfig")[server].setup(config)
        end
      end
    end
  },

  -- 補完
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = "nvim_lsp" },
        },
      })
    end
  },

  -- 検索
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require('telescope').setup()
    end
  },
})

-- =========================
-- キーバインド
-- =========================
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-f>" , ":Telescope find_files<CR>")
vim.keymap.set("n", "<C-g>" , ":Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>g", function()
  vim.cmd("terminal lazygit")
end)