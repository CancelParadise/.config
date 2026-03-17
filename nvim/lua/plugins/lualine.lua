return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = opts.sections or {}

      opts.sections.lualine_a = { "mode" }
      opts.sections.lualine_b = { "branch", "diff", "diagnostics" }
      opts.sections.lualine_c = { "filename" }
      opts.sections.lualine_x = {
        -- Copilot status component
        LazyVim.lualine.status(LazyVim.config.icons.kinds.Copilot, function()
          -- Check if copilot.vim is loaded
          if not vim.g.loaded_copilot then
            return nil
          end

          -- Try to get the client status
          local ok, client = pcall(vim.fn["copilot#RunningClient"])
          if not ok or type(client) ~= "table" then
            return "pending"
          end

          -- Check for startup errors
          if client.startup_error then
            return "error"
          end

          -- Check client status
          if type(client.status) == "table" then
            if client.status.kind == "Error" or client.status.kind == "Warning" then
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
            return nil
          elseif filetypes[ft] == false then
            return nil
          end

          -- Check buffer type
          local buftype = vim.bo.buftype
          if buftype ~= "" and buftype ~= "acwrite" then
            return nil
          end

          return "ok"
        end),
        -- Hardtime status component
        {
          function()
            local ok, hardtime = pcall(require, "hardtime")
            if not ok then
              return ""
            end
            if hardtime.is_plugin_enabled then
              return "⚒"
            else
              return "⚒"
            end
          end,
          color = function()
            local ok, hardtime = pcall(require, "hardtime")
            if ok and hardtime.is_plugin_enabled then
              return { fg = "#a6e3a1" }
            end

            return { fg = "#6c7086" }
          end,
        },
        "encoding",
        "fileformat",
        "filetype",
      }
      opts.sections.lualine_y = { "progress" }
      opts.sections.lualine_z = { "location" }
    end,
  },
}
