return {
  "zbirenbaum/copilot.lua",
  lazy = false,
  opts = {
    suggestion = {
      enabled = not vim.g.ai_cmp,
      auto_trigger = true,
      hide_during_completion = vim.g.ai_cmp,
      keymap = {
        accept = false, -- handled by nvim-cmp / blink.cmp
        next = "<M-]>",
        prev = "<M-[>",
      },
    },
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "BufReadPost",
  config = function(_, opts)
    require("copilot").setup(opts)

    local copilot_suggestion = require("copilot.suggestion")
    vim.keymap.set("i", "<M-l>", function()
      copilot_suggestion.accept()
    end, { noremap = true, silent = true })

    LazyVim.cmp.actions.ai_accept = function()
      if require("copilot.suggestion").is_visible() then
        LazyVim.create_undo()
        require("copilot.suggestion").accept()
        return true
      end
    end
  end,
}
