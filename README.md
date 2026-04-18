# 🧠 Neovim 開発環境（Windows）

Neovim + WezTerm + lazygit を使った
**どのPCでも再現可能な開発環境**です。

---

## 🚀 特徴

- 📂 ファイルツリー（nvim-tree）
- 🔀 Git操作（lazygit）
- 🧠 コード補完（LSP + nvim-cmp）

---

## 📦 必要な環境（事前インストール）

### 必須

```bash
winget install JesseDuffield.lazygit
```

---

## 🧠 LSP（言語サーバー）

```bash
npm install -g typescript typescript-language-server
pip install pyright
go install golang.org/x/tools/gopls@latest
```

---

## 📁 セットアップ手順

### ① 設定をクローン

```bash
git clone <このリポジトリ> %LOCALAPPDATA%\nvim
```

---

### ② lazy.nvim インストール（初回のみ）

```bash
git clone https://github.com/folke/lazy.nvim %LOCALAPPDATA%\nvim-data\lazy\lazy.nvim
```

---

### ③ 起動

```bash
nvim
```

👉 初回起動でプラグインが自動インストールされます

---

## ✅ 動作確認

```vim
:LspInfo
```

以下が表示されればOK：

- ts_ls
- pyright
- gopls

---
