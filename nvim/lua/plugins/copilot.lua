return {
  "zbirenbaum/copilot.lua",
  lazy = false,
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
    },
    panel = {
      enabled = true,
      keymap = {
        accept = "<C-l>",
      },
    },
  },
  config = function(_, opts)
    require("copilot").setup(opts)

    local copilot_suggestion = require("copilot.suggestion")
    vim.keymap.set("i", "<C-l>", function()
      copilot_suggestion.accept()
    end, { noremap = true, silent = true })
  end,
}
