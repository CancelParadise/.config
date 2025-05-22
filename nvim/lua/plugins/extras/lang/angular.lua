return {
  {
    "nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "angular", "scss" })
      end
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        pattern = { "*.component.html", "*.container.html" },
        callback = function()
          vim.treesitter.start(nil, "angular")
        end,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        angularls = {
          on_attach = function(client)
            -- HACK: Disable Angular rename capability to prevent duplicate rename prompt
            client.server_capabilities.renameProvider = false
          end,
        },
        vtsls = {
          settings = {
            tsserver = {
              globalPlugins = { "@angular/language-server" },
              pluginProbeLocations = {
                vim.fn.stdpath("data") .. "/lazy/angular-language-server/node_modules/@angular/language-server",
              },
              enableForWorkspaceTypeScriptVersions = false,
            },
          },
        },
      },
    },
  },
  {
    "conform.nvim",
    opts = function(_, opts)
      if LazyVim.has_extra("formatting.prettier") then
        opts.formatters_by_ft = opts.formatters_by_ft or {}
        opts.formatters_by_ft.htmlangular = { "prettier" }
      end
    end,
  },
}
