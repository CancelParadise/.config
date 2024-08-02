return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      filetypes = { ["*"] = true },
      suggestion = { enabled = true, auto_trigger = true },
    },
  },

  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = true,
  },
  {
    "nvim-cmp",
    dependencies = {
      -- "f3fora/cmp-spell",
      -- "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      -- "jc-doyle/cmp-pandoc-references",
      "petertriho/cmp-git",
      "rcarriga/cmp-dap",
      "hrsh7th/cmp-cmdline",
      { "windwp/nvim-autopairs", opts = {} },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")

      table.insert(opts.sources, { name = "git" })
      table.insert(opts.sources, { name = "emoji" })
      opts.window = {
        completion = {
          border = "rounded",
          winhighlight = "Normal:Pmenu",
        },
        documentation = {
          border = "rounded",
          winhighlight = "Normal:Pmenu",
        },
      }

      cmp.setup.filetype({ "dap-repl", "dapui_watches" }, {
        sources = { { name = "dap" } },
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
    end,
  },
  {
    "Wansmer/treesj",
    keys = {
      { "J", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
    },
    opts = { use_default_keymaps = false, max_join_length = 150 },
  },

  {
    "andythigpen/nvim-coverage",
    event = "VeryLazy",
    config = true,
  },

  {
    "pwntester/codeql.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "telescope.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "s1n7ax/nvim-window-picker",
        version = "v1.*",
        opts = {
          autoselect_one = true,
          include_current = false,
          filter_rules = {
            bo = {
              filetype = {
                "codeql_panel",
                "codeql_explorer",
                "qf",
                "TelescopePrompt",
                "TelescopeResults",
                "notify",
                "NvimTree",
                "neo-tree",
              },
              buftype = { "terminal" },
            },
          },
          current_win_hl_color = "#e35e4f",
          other_win_hl_color = "#44cc41",
        },
      },
    },
    opts = {
      additional_packs = {
        "/opt/codeql",
      },
    },
    cmd = { "QL" },
  },
  { "wakatime/vim-wakatime", event = "VeryLazy" },
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
    init = function()
      vim.o.mps = vim.o.mps .. ',<:>,":"'
    end,
    config = function()
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_offscreen = { method = "status_manual" }
    end,
  },
}
