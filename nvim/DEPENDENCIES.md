# 📦 Dependency Installation

This project relies on various dependencies to provide a seamless Neovim experience. Below is a comprehensive list of installation commands or instructions to set up the required tools and plugins.

---

## 🛠 Prerequisites
Before proceeding, make sure you have the following tools installed:

1. **Neovim** (>= 0.8.0)
   ```bash
   # Ubuntu/Debian
   sudo apt install neovim

   # macOS
   brew install neovim

   # Windows (via Chocolatey)
   choco install neovim
   ```

2. **Git**
   ```bash
   # Ubuntu/Debian
   sudo apt install git

   # macOS
   brew install git

   # Windows
   choco install git
   ```

3. **Node.js** (for Copilot support)
   ```bash
   # Ubuntu/Debian
   sudo apt install nodejs npm

   # macOS
   brew install node

   # Windows
   choco install nodejs
   ```

4. **Python (>= 3.x)** (Required for certain LSPs and Treesitter support)
   ```bash
   # Ubuntu/Debian
   sudo apt install python3 python3-pip

   # macOS
   brew install python

   # Windows
   choco install python
   ```

5. **Watchman (Optional, for efficient file watching)**
   ```bash
   # Ubuntu/Debian
   sudo apt install watchman

   # macOS
   brew install watchman

   # Windows
   # Download from: https://facebook.github.io/watchman/
   ```

---

## 📦 Plugins and Dependencies

### **Core Plugins**

- [Lazy.nvim](https://github.com/folke/lazy.nvim):
  ```bash
  git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/site/pack/lazy
  ```

- [Copilot](https://github.com/github/copilot.vim):
  ```bash
  git clone https://github.com/github/copilot.vim.git ~/.vim/pack/github/start/copilot.vim
  ```

- [Telescope](https://github.com/nvim-telescope/telescope.nvim):
  ```bash
  git clone https://github.com/nvim-telescope/telescope.nvim ~/.local/share/nvim/site/pack/packer/start/telescope.nvim
  ```

---

### Dependencies for Language Support

#### **Angular**
- Install `angular-language-server` for LSP:
  ```bash
  npm install -g @angular/language-server
  ```

#### **C#**
- Install `csharpier` and `netcoredbg`:
  ```bash
  npm install -g csharpier
  git clone https://github.com/Samsung/netcoredbg ~/.local/share/netcoredbg
  ```

#### **JSON**
- Install `jsonls` (JSON Language-Server):
  ```bash
  npm install -g vscode-langservers-extracted
  ```

#### **Python**
- Install Python Language Servers (`pyright`, etc.):
  ```bash
  pip install pyright
  pip install ruff-lsp
  ```

#### **Rust**
- Install Rust tools:
  ```bash
  rustup install stable
  rustup component add rust-analyzer
  npm install -g codelldb
  ```

#### **TypeScript/JavaScript**
- Install TypeScript and the TypeScript LSP:
  ```bash
  npm install -g typescript typescript-language-server
  ```

-- With the Addition verifying bufferopts/lint fixes DEe

