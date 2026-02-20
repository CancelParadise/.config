# 💤 LazyVim Project

This repository is a **starter template** based on [LazyVim](https://github.com/LazyVim/LazyVim). It provides a preconfigured Neovim setup with various plugins, custom configurations, and key mappings to enhance your workflow.

---

## 🚀 Getting Started

### Prerequisites
Make sure you have the following installed:
- Neovim (>= 0.8.0)
- Git
- [Node.js](https://nodejs.org/) (for Copilot support)
- [Watchman](https://facebook.github.io/watchman/) (optional, for file watching)

### Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/CancelParadise/.config.git ~/.config/nvim
   ```
2. Install plugins and dependencies:
   ```bash
   nvim +Lazy!
   ```

---

## 🛠 Configurations

### Key Highlights
- **Lazy Loading Framework:** Powered by `lazy.nvim` to efficiently load plugins.
- **Custom Keymaps** for enhanced navigation and quick actions.
- **Support for major languages** like Rust, Python, JavaScript, and TypeScript.
- **Copilot Integration:** Easily enable/disable GitHub Copilot.

### Customization
Modify the configuration in the respective `lua/config/` files (e.g., `options.lua`, `keymaps.lua`, `autocmds.lua`).

---

## 🎛️ Keymaps
Here are some of the key user-facing mappings included:

### Buffers
- `<leader>bn` - Next buffer
- `<leader>bp` - Previous buffer
- `<leader>bb` - Switch to other buffer
- `<leader>`   - Switch to other buffer

### Window Management
- `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` - Navigate windows
- `<leader>sv` - Vertical split
- `<leader>sh` - Horizontal split

### Pane Resizing
- `<C-Up>` / `<C-Down>` - Resize horizontally
- `<C-Left>` / `<C-Right>` - Resize vertically

### Copilot
- `<leader>aE` - Enable Copilot
- `<leader>aD` - Disable Copilot
- `<leader>aS` - Check Copilot status

### Others
- `<leader>pa` - Show current file path
- `<CR>` - Ignore `<CR>` in insert mode

---

## 📄 Credits
This project is based on the amazing [LazyVim starter template](https://github.com/LazyVim/LazyVim).
Feel free to contribute and customize it as per your needs.

---

## 🔗 Useful Links
- [LazyVim Documentation](https://lazyvim.github.io/installation)
- [Neovim Documentation](https://neovim.io/doc/user/)
