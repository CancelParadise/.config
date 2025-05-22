--  ╭─────────────────────────────────────────────────────────────────────────────╮
--  │            Keymaps are automatically loaded on the VeryLazy event           │
--  │                     Default keymaps that are always set:                    │
--  │ https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua │
--  ╰─────────────────────────────────────────────────────────────────────────────╯

local util = require("util")
local mapkey = require("util.keymapper").mapvimkey

-- Buffer Navigation
mapkey("<leader>bn", "bnext", "n") -- Next buffer
mapkey("<leader>bp", "bprevious", "n") -- Prev buffer
mapkey("<leader>bb", "e #", "n") -- Switch to Other Buffer
mapkey("<leader>`", "e #", "n") -- Switch to Other Buffer

-- Pane and Window Navigation
mapkey("<C-h>", "<C-w>h", "n") -- Navigate Left
mapkey("<C-j>", "<C-w>j", "n") -- Navigate Down
mapkey("<C-k>", "<C-w>k", "n") -- Navigate Up
mapkey("<C-l>", "<C-w>l", "n") -- Navigate Right
mapkey("<C-h>", "wincmd h", "t") -- Navigate Left
mapkey("<C-j>", "wincmd j", "t") -- Navigate Down
mapkey("<C-k>", "wincmd k", "t") -- Navigate Up
mapkey("<C-l>", "wincmd l", "t") -- Navigate Right
mapkey("<C-h>", "TmuxNavigateLeft", "n") -- Navigate Left
mapkey("<C-j>", "TmuxNavigateDown", "n") -- Navigate Down
mapkey("<C-k>", "TmuxNavigateUp", "n") -- Navigate Up
mapkey("<C-l>", "TmuxNavigateRight", "n") -- Navigate Right

-- Tmux Navigation with Ctrl+Shift+h and Ctrl+Shift+l
mapkey("<C-w>l", "<Cmd>silent !tmux previous-window<CR>", "n") -- Navigate to the previous pane in tmux
mapkey("<C-w>h", "<Cmd>silent !tmux next-window<CR>", "n") -- Navigate to the next pane in tmux

-- Window Management
mapkey("<leader>sv", "vsplit", "n") -- Split Vertically
mapkey("<leader>sh", "split", "n") -- Split Horizontally
mapkey("<C-Up>", "resize +2", "n")
mapkey("<C-Down>", "resize -2", "n")
mapkey("<C-Left>", "vertical resize +2", "n")
mapkey("<C-Right>", "vertical resize -2", "n")

-- Show Full File-Path
mapkey("<leader>pa", "ShowPath", "n") -- Show Full File Path

-- ignore enter in insert mode
vim.keymap.set("i", "<CR>", "<CR>", { noremap = true, silent = true })

-- Indenting
vim.keymap.set("v", "<", "<gv", { silent = true, noremap = true })
vim.keymap.set("v", ">", ">gv", { silent = true, noremap = true })

-- change word with <c-c>
vim.keymap.set("n", "<C-c>", "<cmd>normal! ciw<cr>a")

-- htop
if vim.fn.executable("htop") == 1 then
  vim.keymap.set("n", "<leader>xh", function()
    require("lazyvim.util").float_term({ "htop" })
  end, { desc = "htop" })
end

local function do_open(uri)
  local cmd, err = vim.ui.open(uri)
  local rv = cmd and cmd:wait(1000) or nil
  if cmd and rv and rv.code ~= 0 then
    err = ("vim.ui.open: command %s (%d): %s"):format(
      (rv.code == 124 and "timeout" or "failed"),
      rv.code,
      vim.inspect(cmd.cmd)
    )
  end
  return err
end

--  ╭───────────────────────────────────────────────────────────╮
--  │ Credit: June Gunn <Leader>?/! | Google it / Feeling lucky │
--  ╰───────────────────────────────────────────────────────────╯
---@param pat string
local function google(pat)
  local query = '"' .. vim.fn.substitute(pat, '["\n]', " ", "g") .. '"'
  query = vim.fn.substitute(query, "[[:punct:] ]", [[\=printf("%%%02X", char2nr(submatch(0)))]], "g")
  do_open("https://www.google.com/search?" .. "q=" .. query)
end

vim.keymap.set("n", "<leader>?", function()
  google(vim.fn.expand("<cWORD>"))
end, { desc = "Google" })

vim.keymap.set("x", "<leader>?", function()
  google(vim.fn.getreg("g"))
end, { desc = "Google" })

--  ╭────────────────────────────────────╮
--  │ GX - replicate netrw functionality │
--  ╰────────────────────────────────────╯
local function open_link()
  local url = vim.ui._get_url()
  if url:match("%w://") then
    return do_open(url)
  end

  -- consider anything that looks like string/string a github link
  local plugin_url_regex = "[%a%d%-%.%_]*%/[%a%d%-%.%_]*"
  local link = string.match(url, plugin_url_regex)
  if link then
    return do_open(string.format("https://www.github.com/%s", link))
  end

  vim.notify("No link found under cursor")
end

vim.keymap.set("n", "gx", open_link)
vim.keymap.set("n", "gf", "<cmd>e <cfile><cr>", { desc = "Open File" })

--  ╭──────────╮
--  │ Commands │
--  ╰──────────╯
util.command("ToggleBackground", function()
  vim.o.background = vim.o.background == "dark" and "light" or "dark"
end)

local watch_type = require("vim._watch").FileChangeType

local function handler(res, callback)
  if not res.files or res.is_fresh_instance then
    return
  end

  for _, file in ipairs(res.files) do
    local path = res.root .. "/" .. file.name
    local change = watch_type.Changed
    if file.new then
      change = watch_type.Created
    end
    if not file.exists then
      change = watch_type.Deleted
    end
    callback(path, change)
  end
end

function watchman(path, opts, callback)
  vim.system({ "watchman", "watch", path }):wait()

  local buf = {}
  local sub = vim.system({
    "watchman",
    "-j",
    "--server-encoding=json",
    "-p",
  }, {
    stdin = vim.json.encode({
      "subscribe",
      path,
      "nvim:" .. path,
      {
        expression = { "anyof", { "type", "f" }, { "type", "d" } },
        fields = { "name", "exists", "new" },
      },
    }),
    stdout = function(_, data)
      if not data then
        return
      end
      for line in vim.gsplit(data, "\n", { plain = true, trimempty = true }) do
        table.insert(buf, line)
        if line == "}" then
          local res = vim.json.decode(table.concat(buf))
          handler(res, callback)
          buf = {}
        end
      end
    end,
    text = true,
  })

  return function()
    sub:kill("sigint")
  end
end

if vim.fn.executable("watchman") == 1 then
  require("vim.lsp._watchfiles")._watchfunc = watchman
else
  vim.notify("watchman not found, using default filewatcher")
end
