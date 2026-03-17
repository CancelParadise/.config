return {
  {
    "github/copilot.vim",
    lazy = false,
    event = "InsertEnter",
    config = function()
      -- Remove this line if you want Tab to accept suggestions:
      -- vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true

      -- Accept with Tab (default behavior - optional to set explicitly)
      vim.keymap.set("i", "<Tab>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "Copilot Accept",
      })

      vim.keymap.set("i", "<C-K>", "<Plug>(copilot-dismiss)", { desc = "Copilot Dismiss" })
      vim.keymap.set("i", "<C-L>", "<Plug>(copilot-next)", { desc = "Copilot Next" })
      vim.keymap.set("i", "<C-H>", "<Plug>(copilot-previous)", { desc = "Copilot Previous" })
      vim.keymap.set("i", "<M-\\>", "<Plug>(copilot-suggest)", { desc = "Copilot Suggest" })
      vim.keymap.set("i", "<M-Right>", "<Plug>(copilot-accept-word)", { desc = "Copilot Accept Word" })
      vim.keymap.set("i", "<M-C-Right>", "<Plug>(copilot-accept-line)", { desc = "Copilot Accept Line" })

      -- Disable copilot in certain filetypes
      vim.g.copilot_filetypes = {
        ["*"] = true,
        ["help"] = false,
        ["gitcommit"] = false,
        ["gitrebase"] = false,
        ["."] = false,
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- copilot.lua only works with its own copilot lsp server
        copilot = { enabled = false },
      },
    },
  },
}
