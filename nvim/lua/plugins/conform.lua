return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      html = { "prettier" },
      css = { "prettier" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      cs = { "csharpier" },
    },
    formatters = {
      csharpier = {
        command = "dotnet-csharpier",
        args = { "--write-stdout" },
      },
      prettier = {
        args = {
          "--stdin-filepath",
          "$FILENAME",
          "--print-width",
          "180", -- 👈 increase line length here
        },
      },
    },
  },
}
