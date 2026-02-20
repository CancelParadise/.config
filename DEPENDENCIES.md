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

---

## 🪟 WSL2 (Ubuntu 25.04) Specific Dependencies

If you are running this on **Windows with WSL2 (Ubuntu 25.04)**, follow the steps below to install all required dependencies inside your WSL2 environment.

### System Packages

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git zsh curl wget build-essential unzip ripgrep fd-find python3 python3-pip tmux
```

### Neovim (Latest via PPA)

```bash
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update && sudo apt install -y neovim
```

### Node.js (via NVM)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.zshenv
nvm install --lts
```

### win32yank (Clipboard Integration for WSL2 ↔ Windows)

```bash
curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
chmod +x /tmp/win32yank.exe
sudo mv /tmp/win32yank.exe /usr/local/bin/win32yank.exe
```

### Zsh as Default Shell

```bash
chsh -s $(which zsh)
```

### Set ZDOTDIR for Zsh

Add this line to your `~/.zshenv`:

```bash
echo 'export ZDOTDIR="$HOME/.config/zsh"' >> ~/.zshenv
```

### Tmux Plugin Manager (TPM)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

> After starting tmux, press `Ctrl+a` then `I` to install all plugins.

### JetBrains Mono Nerd Font

Install on **Windows** (not inside WSL):

1. Download from [NerdFonts](https://www.nerdfonts.com/font-downloads)
2. Extract and double-click to install each `.ttf` file
3. Set the font in your terminal emulator (WezTerm, Kitty, Alacritty, or Windows Terminal)

### Recommended `.wslconfig` (Windows-side)

Create `C:\Users\<YourUsername>\.wslconfig`:

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
```

> Adjust values based on your machine's available RAM and CPU cores.

