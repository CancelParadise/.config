return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "AndreM222/copilot-lualine" },
    opts = function(_, opts)
      -- ตั้งค่า copilot-lualine ก่อน
      require("copilot-lualine").setup({
        show_colors = true,
        show_loading = true,
        symbols = {
          status = {
            icons = {
              enabled = "🤖",  -- Copilot เปิดใช้งาน
              sleep = "😴",    -- auto-trigger ปิด
              disabled = "🚫", -- Copilot ปิด
              warning = "⚠️",  -- มีปัญหา
              unknown = "❓",  -- ไม่ทราบสถานะ
            },
            hl = {
              enabled = "#50FA7B",  -- สีเขียว
              sleep = "#AEB7D0",    -- สีเทา
              disabled = "#6272A4", -- สีเทาเข้ม
              warning = "#FFB86C",  -- สีส้ม
              unknown = "#FF5555",  -- สีแดง
            },
          },
          spinners = "dots", -- animation loading
          spinner_color = "#6272A4",
        },
      })
      
      -- เพิ่ม copilot component เข้า lualine_x
      table.insert(opts.sections.lualine_x, require("copilot-lualine").component)
      
      -- เพิ่ม emoji สนุกๆ ตามเดิม
      table.insert(opts.sections.lualine_x, {
        function()
          return "😄"
        end,
      })
    end,
  },
}