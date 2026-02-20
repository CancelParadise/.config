# 💤 Dotfiles

This repository is a **full dotfiles configuration** covering Neovim (powered by [LazyVim](https://github.com/LazyVim/LazyVim)), Tmux, Zsh, and terminal emulators (WezTerm, Kitty, Alacritty). It provides a preconfigured, ready-to-use development environment for Linux/macOS.

---

## 📁 Project Structure

```
~config/
├── nvim/           # Neovim configuration (LazyVim-based)
├── tmux/           # Tmux configuration with TPM plugins
├── zsh/            # Zsh configuration with Powerlevel10k
├── wezterm/        # WezTerm terminal configuration
├── kitty/          # Kitty terminal configuration
└── alacritty/      # Alacritty terminal configuration
```

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed before proceeding:

| Tool | Version | Purpose |
|------|---------|---------|
| [Neovim](https://neovim.io/) | >= 0.8.0 | Main editor |
| [Git](https://git-scm.com/) | Latest | Version control & plugin manager |
| [Node.js](https://nodejs.org/) | Latest | Copilot & LSP support |
| [Python](https://www.python.org/) | >= 3.x | LSP & Treesitter support |
| [tmux](https://github.com/tmux/tmux) | Latest | Terminal multiplexer |
| [Zsh](https://www.zsh.org/) | Latest | Shell |
| [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads) | Latest | Terminal font (required for icons) |
| [Watchman](https://facebook.github.io/watchman/) | Latest | File watching (optional) |

> For step-by-step installation of all dependencies, refer to [DEPENDENCIES.md](./DEPENDENCIES.md).

---

### Installation

1. **Back up your existing config** (if any):
   ```bash
   mv ~/.config ~/.config.bak
   ```

2. **Clone this repository** into `~/.config`:
   ```bash
   git clone https://github.com/CancelParadise/.config.git ~/.config
   ```

3. **Install Neovim plugins** (LazyVim will auto-bootstrap on first launch):
   ```bash
   nvim
   ```
   > Wait for all plugins to install, then restart Neovim.

4. **Install Tmux plugins** via TPM:
   - First, install TPM:
     ```bash
     git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
     ```
   - Start tmux, then press `prefix + I` (default prefix is `Ctrl+a`) to install all plugins:
     ```bash
     tmux
     ```

5. **Set up Zsh**:
   - Make sure your `ZDOTDIR` is set to `~/.config/zsh`:
     ```bash
     echo 'export ZDOTDIR="$HOME/.config/zsh"' >> ~/.zshenv
     ```
   - Install [Powerlevel10k](https://github.com/romkatv/powerlevel10k) font and run `p10k configure` to set up the prompt.

6. **Install a Nerd Font** (JetBrains Mono recommended):
   - Download from [NerdFonts](https://www.nerdfonts.com/font-downloads) and install it in your terminal emulator.

---

## 🪟 Windows + WSL2 (Ubuntu 25.04) Setup

This dotfiles configuration works great on **Windows with WSL2** running **Ubuntu 25.04**. Follow the steps below for the best experience.

### 1. Install WSL2 + Ubuntu 25.04

Open **PowerShell as Administrator** and run:

```powershell
wsl --install -d Ubuntu-25.04
```

> If Ubuntu 25.04 is not listed yet, check available distros with:
> ```powershell
> wsl --list --online
> ```

After installation, restart your machine and launch Ubuntu from the Start menu to complete setup.

---

### 2. Install Windows Terminal (Recommended)

Download [Windows Terminal](https://aka.ms/terminal) from the Microsoft Store for the best terminal experience on Windows.

> **Tip:** Set your default profile to **Ubuntu-25.04** and configure the font to **JetBrains Mono Nerd Font** in the appearance settings.

---

### 3. Install JetBrains Mono Nerd Font on Windows

All terminal emulators (WezTerm, Kitty, Alacritty) require the **JetBrains Mono Nerd Font**.

1. Download from [NerdFonts](https://www.nerdfonts.com/font-downloads)
2. Extract and install the font on **Windows** (not inside WSL)
3. Set the font in your terminal emulator settings

---

### 4. Set Up Ubuntu 25.04 Dependencies

Inside your WSL2 Ubuntu terminal, run:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git zsh curl wget build-essential unzip ripgrep fd-find python3 python3-pip
```

Install **Neovim** (latest via PPA or AppImage):

```bash
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update && sudo apt install -y neovim
```

Install **Node.js** via NVM:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.zshenv
nvm install --lts
```

Install **tmux**:

```bash
sudo apt install -y tmux
```

---

### 5. Set Zsh as Default Shell

```bash
chsh -s $(which zsh)
```

> Close and reopen your terminal for the change to take effect.

---

### 6. Clone and Apply Dotfiles

```bash
mv ~/.config ~/.config.bak  # backup existing config if any
git clone https://github.com/CancelParadise/.config.git ~/.config
echo 'export ZDOTDIR="$HOME/.config/zsh"' >> ~/.zshenv
source ~/.zshenv
```

---

### 7. Clipboard Integration (WSL2 ↔ Windows)

Clipboard between WSL2 and Windows is handled automatically via:

- **`wsl_clip.lua`** – Uses `clip.exe` for copy and `powershell.exe` for paste with CRLF normalization.
- **`wsl_yank.lua`** – Uses `win32yank.exe` for clipboard sync.

To use `win32yank.exe`, install it on Windows and make sure it is accessible in your WSL2 `$PATH`:

```bash
# Download win32yank and place it in /usr/local/bin
curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
chmod +x /tmp/win32yank.exe
sudo mv /tmp/win32yank.exe /usr/local/bin/win32yank.exe
```

> No extra config is needed — Neovim detects WSL automatically and applies the correct clipboard provider.

---

### 8. Terminal Emulators on Windows

You can run any of the included terminal configs from Windows:

| Terminal | Installation | Notes |
|----------|-------------|-------|
| **WezTerm** | [wezfurlong.org](https://wezfurlong.org/wezterm/) | Best WSL2 support, Tokyo Night theme |
| **Kitty** | [sw.kovidgoyal.net/kitty](https://sw.kovidgoyal.net/kitty/) | Custom dark theme |
| **Alacritty** | [alacritty.org](https://alacritty.org/) | Nightfox theme |
| **Windows Terminal** | [Microsoft Store](https://aka.ms/terminal) | Easiest setup for WSL2 |

> All configs are stored in `~/.config/wezterm/`, `~/.config/kitty/`, and `~/.config/alacritty/`.

---

### 9. Recommended WSL2 `.wslconfig` (Windows-side)

Create a `.wslconfig` file in `C:\Users\<YourUsername>\.wslconfig` to tune WSL2 performance:

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
```

> Adjust values based on your machine's RAM and CPU.

---

## 🛠 Configurations

### Neovim (`nvim/`)

Powered by **LazyVim** with the following highlights:

- **Lazy Loading** via `lazy.nvim` for fast startup.
- **AI Assistant** via `avante.nvim` (uses GitHub Copilot with `claude-sonnet` model).
- **GitHub Copilot** integration with toggle support.
- **LSP Support** via `mason.nvim` for auto-installing language servers.
- **Debugging** via `nvim-dap` with a configured DAP setup.
- **Code Formatting** via `conform.nvim`.
- **Diagnostics** via `trouble.nvim`.
- **Fuzzy Finder** via `telescope.nvim`.
- **Syntax Highlighting** via `nvim-treesitter`.
- **Status Line** via `lualine.nvim`.
- **Language Support**: Rust, Python, JavaScript, TypeScript, C#, Angular, JSON.
- **WSL Support**: Clipboard integration for WSL environments.

#### Neovim Directory Layout

```
nvim/
├── init.lua                # Entry point
├── lua/
│   ├── config/
│   │   ├── autocmds.lua    # Auto commands
│   │   ├── keymaps.lua     # Custom keymaps
│   │   ├── lazy.lua        # Plugin manager setup
│   │   └── options.lua     # Neovim options
│   ├── plugins/            # Plugin configurations
│   │   ├── avante.lua      # AI assistant
│   │   ├── copilot.lua     # GitHub Copilot
│   │   ├── dap.lua         # Debugger
│   │   ├── mason.lua       # LSP installer
│   │   ├── telescope.lua   # Fuzzy finder
│   │   ├── treesitter.lua  # Syntax highlighting
│   │   ├── conform.lua     # Code formatting
│   │   ├── trouble.lua     # Diagnostics
│   │   └── lualine.lua     # Status line
│   └── util/               # Utility functions
└── after/plugin/
    └── dap.lua             # DAP post-configuration
```

### Tmux (`tmux/`)

- **Prefix**: `Ctrl+a`
- **Vim-style pane navigation** (`C-h/j/k/l`)
- **Seamless Neovim ↔ Tmux navigation** via `vim-tmux-navigator`
- **Session persistence** via `tmux-resurrect` & `tmux-continuum` (auto-save every 1 min)
- **Status bar** with CPU, memory, battery, online status, date/time

#### Tmux Plugins

| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tpm` | Plugin manager |
| `christoomey/vim-tmux-navigator` | Seamless nvim/tmux navigation |
| `tmux-plugins/tmux-resurrect` | Session persistence across restarts |
| `tmux-plugins/tmux-continuum` | Auto-save sessions every 1 minute |
| `tmux-plugins/tmux-yank` | Better yank support |
| `tmux-plugins/tmux-battery` | Battery status in status bar |
| `samoshkin/tmux-plugin-sysstat` | CPU/memory stats in status bar |

### Zsh (`zsh/`)

- **Prompt**: [Powerlevel10k](https://github.com/romkatv/powerlevel10k) with instant prompt
- **History**: 100,000 entries with substring search
- **Plugins**: Managed via `pluginrc`
- **Aliases**: Defined in `aliasrc`
- **NVM**: Auto-loaded for Node.js version management
- **XDG compliance**: `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_CACHE_HOME` set

### Terminals

| Terminal | Config | Theme |
|----------|--------|-------|
| **WezTerm** | `wezterm/wezterm.lua` | Tokyo Night |
| **Kitty** | `kitty/kitty.conf` | Custom dark |
| **Alacritty** | `alacritty/alacritty.toml` | Nightfox |

All terminals use **JetBrains Mono Nerd Font** at size 12 with slight transparency.

---

## 🎛️ Keymaps

> `<leader>` is `Space` by default (LazyVim default).

### Buffers

| Keymap | Action |
|--------|--------|
| `<leader>bn` | Next buffer |
| `<leader>bp` | Previous buffer |
| `<leader>bb` | Switch to other buffer |
| `` <leader>` `` | Switch to other buffer |

### Window Management

| Keymap | Action |
|--------|--------|
| `<C-h/j/k/l>` | Navigate windows / tmux panes |
| `<leader>sv` | Split vertically |
| `<leader>sh` | Split horizontally |
| `<C-Up/Down>` | Resize pane horizontally |
| `<C-Left/Right>` | Resize pane vertically |
| `<C-w>l` | Previous tmux window |
| `<C-w>h` | Next tmux window |

### Editing

| Keymap | Action |
|--------|--------|
| `<` / `>` (visual) | Indent left/right (stays in visual mode) |
| `<C-c>` | Change word under cursor |
| `gx` | Open link under cursor |
| `gf` | Open file under cursor |

### Copilot

| Keymap | Action |
|--------|--------|
| `<leader>aE` | Enable Copilot |
| `<leader>aD` | Disable Copilot |
| `<leader>aS` | Check Copilot status |

### Avante AI Assistant

| Keymap | Action |
|--------|--------|
| `<leader>aa` | Ask Avante |
| `<leader>ac` | Chat with Avante |
| `<leader>ae` | Edit with Avante |
| `<leader>af` | Focus Avante |
| `<leader>ah` | Avante history |
| `<leader>am` | Select Avante model |
| `<leader>an` | New Avante chat |
| `<leader>ap` | Switch Avante provider |
| `<leader>ar` | Refresh Avante |
| `<leader>as` | Stop Avante |
| `<leader>at` | Toggle Avante |

### Utilities

| Keymap | Action |
|--------|--------|
| `<leader>pa` | Show current file path |
| `<leader>xh` | Open htop (if installed) |
| `<leader>?` | Google word under cursor |
| `<leader>?` (visual) | Google selected text |
| `:ToggleBackground` | Toggle light/dark background |

---

## 📄 Credits

This project is based on the amazing [LazyVim starter template](https://github.com/LazyVim/LazyVim).
Feel free to contribute and customize it as per your needs.

---

## 🔗 Useful Links

- [LazyVim Documentation](https://lazyvim.github.io/installation)
- [Neovim Documentation](https://neovim.io/doc/user/)
- [Tmux Wiki](https://github.com/tmux/tmux/wiki)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [WezTerm Documentation](https://wezfurlong.org/wezterm/)
- [NerdFonts](https://www.nerdfonts.com/)
- [DEPENDENCIES.md](./DEPENDENCIES.md)
