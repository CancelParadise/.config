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
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(
        opts.sections.lualine_x,
        2,
        LazyVim.lualine.status(LazyVim.config.icons.kinds.Copilot, function()
          -- Check if copilot. vim is loaded
          if not vim.g.loaded_copilot then
            return nil
          end

          -- Try to get the client status (requires calling VimScript)
          local ok, client = pcall(vim.fn["copilot#RunningClient"])
          if not ok or type(client) ~= "table" then
            -- Client not running yet
            return "pending"
          end

          -- Check for startup errors
          if client.startup_error then
            return "error"
          end

          -- Check client status (if available)
          if type(client.status) == "table" then
            if client.status.kind == "Error" then
              return "error"
            elseif client.status.kind == "Warning" then
              return "error"
            end
          end

          -- Check if globally disabled
          if vim.g.copilot_enabled == 0 then
            return "error"
          end

          -- Check if disabled for current buffer
          if vim.b.copilot_enabled == false or vim.b.copilot_disabled then
            return "error"
          end

          -- Check if disabled for current filetype
          local filetypes = vim.g.copilot_filetypes or {}
          local ft = vim.bo.filetype
          if filetypes["*"] == false and filetypes[ft] ~= true then
            return nil -- Hidden for disabled filetypes
          elseif filetypes[ft] == false then
            return nil
          end

          -- Check buffer type
          local buftype = vim.bo.buftype
          if buftype ~= "" and buftype ~= "acwrite" then
            return nil
          end

          -- All checks passed - Copilot is active and ready
          return "ok"
        end)
      )
    end,
  },
}
