# Copilot Instructions

## Build, test, and lint commands

- There is no repo-wide build command, CI entrypoint, `Makefile`, or package manifest at the repository root. This is a dotfiles repo centered on editor, shell, tmux, and terminal configuration.
- Bootstrap Neovim plugins by launching `nvim`. `nvim/lua/config/lazy.lua` clones `lazy.nvim` automatically on first start and imports all specs from `nvim/lua/plugins/`.
- Install tmux plugins by starting `tmux` and pressing `Ctrl+a` then `I` after TPM is installed, matching `README.md` and `tmux/tmux.conf`.
- Lua formatting is configured with `nvim/stylua.toml`. Use `stylua --config-path nvim/stylua.toml nvim` when formatting Neovim Lua files.
- `nvim/lua/plugins/mason.lua` ensures editor-side tools such as `stylua`, `shellcheck`, `shfmt`, and `flake8`.
- There is no checked-in automated test suite today. The only explicit test helper is in `nvim/lua/util/init.lua`:
  - `:lua require("util").test()` runs the `./tests` directory through Plenary if tests are added.
  - `:lua require("util").test(true)` targets the current file as the single-test workflow.

## High-level architecture

- This repository is a unified `~/.config` setup. The main subsystems are `nvim/`, `tmux/`, `zsh/`, and terminal emulator configs under `wezterm/`, `kitty/`, and `alacritty/`.
- `nvim/` is the most code-heavy area. `nvim/init.lua` is intentionally minimal: it bootstraps LazyVim via `config.lazy` and then loads WSL- and input-specific modules such as `wsl_clip`, `wsl_yank`, and `mouse`.
- `nvim/lua/config/lazy.lua` is the Neovim composition point. It imports the upstream LazyVim plugin set and then `{ import = "plugins" }`, so repository-specific editor behavior is spread across `nvim/lua/plugins/*.lua` and language extras in `nvim/lua/plugins/extras/lang/*.lua`. `nvim/lazyvim.json` declares which language extras are active.
- `tmux/tmux.conf` and `nvim/lua/config/keymaps.lua` are designed together. Pane movement, window navigation, and editor behavior are coordinated so `Ctrl+h/j/k/l` works across Neovim windows and tmux panes.
- `zsh/.zshrc` is only the shell entrypoint. It delegates almost all behavior to `aliasrc`, `optionrc`, and `pluginrc` under `ZDOTDIR`, while also setting XDG paths and Powerlevel10k startup.
- WSL support is built into the Neovim startup path instead of being a separate optional layer. `nvim/lua/wsl_clip.lua` and `nvim/lua/wsl_yank.lua` define clipboard behavior for Windows interop, including CRLF-to-LF normalization on paste.

## Key conventions

- For Neovim changes, prefer the existing Lazy spec layout instead of adding logic directly to `init.lua`. New plugin behavior usually belongs in `nvim/lua/plugins/*.lua`, and language-specific behavior belongs in `nvim/lua/plugins/extras/lang/*.lua`.
- Keep `lazyvim.json` aligned with language extras. Adding or removing an extra under `nvim/lua/plugins/extras/lang/` should usually be reflected there.
- Reuse `nvim/lua/util/keymapper.lua` for Neovim mappings when possible. The config already wraps command-style mappings with `mapvimkey()` and lazy-loaded plugin mappings with `maplazykey()`, and `nvim/lua/config/keymaps.lua` follows that pattern.
- Preserve the tmux/Neovim navigation contract. `tmux/tmux.conf` binds `C-h/j/k/l`, and `nvim/lua/config/keymaps.lua` maps the same keys to both local window movement and `TmuxNavigate*`.
- Keep Zsh modular. Changes should usually land in `zsh/aliasrc`, `zsh/optionrc`, or `zsh/pluginrc` instead of expanding `.zshrc`, and `.zshrc` must keep the Powerlevel10k instant prompt block near the top.
- `zsh/pluginrc` manages shell plugins by sourcing them from `/etc/zsh/plugins` and auto-installing missing plugins with `sudo git clone`. Follow that pattern unless the plugin system is being changed intentionally across the repo.
- Terminal configs are kept parallel rather than centralized. `wezterm/wezterm.lua`, `kitty/kitty.conf`, and `alacritty/alacritty.toml` all independently encode the shared font/theme preferences, so visual changes often need to be applied in more than one place.
- When README guidance and source files disagree, prefer the source files as the source of truth and update docs only when the implementation change is intentional.
