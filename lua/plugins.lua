-- lazy.nvim の自動インストール (bootstrap)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP / Mason
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",

  -- Completion & editing
  { "saghen/blink.cmp", version = "1.*" },
  "windwp/nvim-autopairs",

  -- Theme & UI
  { "folke/tokyonight.nvim", priority = 1000 },
  { "folke/snacks.nvim", priority = 1000 },
  "folke/noice.nvim",
  "MunifTanjim/nui.nvim",
  "nvim-tree/nvim-web-devicons",

  -- File explorer
  "stevearc/oil.nvim",
  "refractalize/oil-git-status.nvim",

  -- Search & navigation
  "nvim-lua/plenary.nvim",          -- Telescope が内部で使う部品集
  "nvim-telescope/telescope.nvim",  -- 検索画面の本体
  "nvim-telescope/telescope-live-grep-args.nvim",
  "nvim-telescope/telescope-frecency.nvim",
  "folke/flash.nvim",
  "dnlhc/glance.nvim",
  "kevinhwang91/nvim-bqf",

  -- Git
  "lewis6991/gitsigns.nvim",
  "sindrets/diffview.nvim",

  -- Formatter
  "stevearc/conform.nvim",
}, {
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = false },
})
