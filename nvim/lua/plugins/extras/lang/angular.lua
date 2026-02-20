return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "angular", "scss" })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.angularls = {
        cmd = { vim.fn.expand("~/.local/bin/ngserver-wrapper") },
        filetypes = { "html", "typescript", "typescriptreact", "typescript.tsx" },
      }
      opts.servers.vtsls = vim.tbl_deep_extend("force", opts.servers.vtsls or {}, {
        filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
      })

      -- สร้าง autocommand เพื่อ setup angularls เมื่อเปิดไฟล์ HTML
      opts.setup = opts.setup or {}
      opts.setup.angularls = function(_, server_opts)
        require("lspconfig").angularls.setup(server_opts)
      end

      return opts
    end,
  },
  {
    "nvim-mason/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "angular-language-server" })
    end,
  },
}
