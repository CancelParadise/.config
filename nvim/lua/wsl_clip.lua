-- WSL Neovim clipboard provider that normalizes CRLF -> LF on paste.
-- Save as ~/.config/nvim/lua/wsl_clip.lua and add `require('wsl_clip')` to your init.lua

if vim.fn.has("wsl") ~= 1 then
  return
end

local function has(exe)
  return vim.fn.executable(exe) == 1
end

-- Prefer clip.exe for copy, and powershell for paste (but normalize CRs)
local copy_cmd
if has("clip.exe") then
  copy_cmd = { "clip.exe" } -- reads stdin
elseif has("powershell.exe") then
  copy_cmd = {
    "powershell.exe",
    "-NoProfile",
    "-NonInteractive",
    "-Command",
    "Set-Clipboard -Value ([Console]::In.ReadToEnd())",
  }
else
  -- fallback no-op
  copy_cmd = { "sh", "-c", "cat >/dev/null" }
end

-- For paste we pipe powershell output through tr -d "\\r" to remove CR chars.
-- If powershell.exe isn't available, fallback to cat (empty/no-op).
local paste_cmd
if has("powershell.exe") then
  -- Use sh -c to ensure Neovim validates 'sh' as executable; pipe output to tr to strip \r
  paste_cmd = { "sh", "-c", 'powershell.exe -NoProfile -NonInteractive -Command "Get-Clipboard -Raw" | tr -d "\\r"' }
elseif has("clip.exe") then
  -- clip.exe doesn't provide clipboard read; fallback to cat
  paste_cmd = { "sh", "-c", "cat" }
else
  paste_cmd = { "sh", "-c", "cat" }
end

vim.g.clipboard = {
  name = "wsl-clipboard-normalized",
  copy = { ["+"] = copy_cmd, ["*"] = copy_cmd },
  paste = { ["+"] = paste_cmd, ["*"] = paste_cmd },
  cache_enabled = true,
}
