return {
  -- Active colorscheme configuration
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "night",
      styles = {
        keywords = { italic = false },
        sidebars = "transparent",
        floats = "transparent",
      },
      transparent = true,
      sidebars = {
        "qf",
        "vista_kind",
        "spectre_panel",
        "NeogitStatus",
        "startuptime",
        "Outline",
      },
    },
  },
}
