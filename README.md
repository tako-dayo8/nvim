# Neovim 開発環境（Windows）

---

## 🚀 特徴

- 📂 ファイルツリー（nvim-tree）
- 🔀 Git操作（lazygit）
- 🧠 コード補完（LSP + nvim-cmp）

---

## 📦 必要な環境（事前インストール）

# Neovim 開発環境

Neovim + lazygit + LSP を使った
**クロスプラットフォーム開発環境（Windows / Linux対応）**

---

## 🚀 特徴

* 📂 ファイルツリー（nvim-tree）
* 🔀 Git操作（lazygit）
* 🧠 コード補完（LSP + nvim-cmp）

---

# 🪟 Windows セットアップ

## 📦 必須

```bash
winget install JesseDuffield.lazygit
```

---

## 📁 設定配置

```bash
git clone https://github.com/tako-dayo8/nvim.git %LOCALAPPDATA%\nvim
```

---

## 📦 lazy.nvim

```bash
git clone https://github.com/folke/lazy.nvim %LOCALAPPDATA%\nvim-data\lazy\lazy.nvim
```

---

## ▶️ 起動

```bash
nvim
```

---

# 🐧 Linux セットアップ

## 📦 必須（Ubuntu例）

```bash
sudo apt update
sudo apt install neovim git nodejs npm python3 python3-pip golang lazygit
```

---

## 📁 設定配置

```bash
git clone <このリポジトリ> ~/.config/nvim
```

---

## 📦 lazy.nvim

```bash
git clone https://github.com/folke/lazy.nvim ~/.local/share/nvim/lazy/lazy.nvim
```

---

## ▶️ 起動

```bash
nvim
```

---

# 🧠 LSP（共通）

```bash
npm install -g typescript typescript-language-server
pip install pyright
go install golang.org/x/tools/gopls@latest
```

---

# ✅ 動作確認

```vim
:LspInfo
```

以下が表示されればOK：

* ts_ls
* pyright
* gopls


