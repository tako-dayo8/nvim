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

require("mason").setup()
require("mason-lspconfig").setup({
  -- 自動で入れておきたいLSPサーバーを列挙
  ensure_installed = {
    "bashls",
    "lua_ls",
    "ts_ls",
    "gopls",
    "pylsp",
    "marksman",
  },
  -- インストール済みのLSPを自動で vim.lsp.enable() する（Neovim 0.11+）
  automatic_enable = true,
})

-- エラーや警告を行の右側に表示する(既定では非表示)
vim.diagnostic.config({ virtual_text = true })
