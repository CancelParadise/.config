-- nvim-hardtime config
-- Enable:  <leader>he
-- Disable: <leader>hd
return {
  {
    "m4xshen/hardtime.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    opts = {
      enabled = false, -- default state; you can set to false if you want it off at startup
    },
    config = function(_, opts)
      -- Setup the plugin first so its commands get registered
      require("hardtime").setup(opts)

      -- Keymaps
      -- (These call the plugin's user commands.)
      vim.keymap.set("n", "<leader>he", "<cmd>Hardtime enable<cr>", {
        desc = "Hardtime: enable",
        silent = true,
      })

      vim.keymap.set("n", "<leader>hd", "<cmd>Hardtime disable<cr>", {
        desc = "Hardtime: disable",
        silent = true,
      })
    end,
  },
}
