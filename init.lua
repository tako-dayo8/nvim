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
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "\\lazy\\lazy.nvim")

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

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- TypeScript / JavaScript
      lspconfig.ts_ls.setup({
        filetypes = {
          "javascript", "javascriptreact",
          "typescript", "typescriptreact"
        }
      })

      -- Python
      lspconfig.pyright.setup({})

      -- Go
      lspconfig.gopls.setup({})
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

})

-- =========================
-- キーバインド
-- =========================
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- nvim-tree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- lazygit
vim.keymap.set("n", "<leader>g", function()
  vim.cmd("terminal lazygit")
end)