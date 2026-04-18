-- lazy.nvimのパス追加（Windows版）
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "\\lazy\\lazy.nvim")

require("lazy").setup({
  -- ファイルツリー
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup()
    end
  },

  -- Git差分
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end
  },

  -- LSP
  {
    "neovim/nvim-lspconfig"
  },

  -- 補完
  {
    "hrsh7th/nvim-cmp"
  }
})

-- 基本設定
vim.opt.number = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true