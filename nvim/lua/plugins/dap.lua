return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- Setup UI
    dapui.setup()
    require("nvim-dap-virtual-text").setup()

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -----------------------------------------------------
    -- Force clear default configs for C#
    -----------------------------------------------------
    dap.configurations.cs = {}
    dap.configurations.fsharp = {}
    dap.configurations.vb = {}

    -----------------------------------------------------
    -- Adapter
    -----------------------------------------------------
    dap.adapters.netcoredbg = {
      type = "executable",
      command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
      args = { "--interpreter=vscode" },
      options = { detached = false },
    }

    -----------------------------------------------------
    -- Load launchSettings.json
    -----------------------------------------------------
    local function load_launch_settings()
      local json = vim.fn.getcwd() .. "/Properties/launchSettings.json"
      local profiles = {}
      local ok, data = pcall(vim.fn.json_decode, vim.fn.readfile(json))
      if ok and data and data.profiles then
        for name, _ in pairs(data.profiles) do
          table.insert(profiles, {
            type = "netcoredbg",
            name = "Launch profile: " .. name,
            request = "launch",
            program = function()
              return vim.fn.input("Path to dll (built project): ", vim.fn.getcwd() .. "/bin/Debug/net8.0/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopAtEntry = false,
            console = "integratedTerminal",
          })
        end
      end
      return profiles
    end

    -----------------------------------------------------
    -- Final C# configs
    -----------------------------------------------------
    dap.configurations.cs = vim.list_extend(load_launch_settings(), {
      {
        type = "netcoredbg",
        name = "Launch .NET Core (manual)",
        request = "launch",
        program = function()
          return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/net8.0/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtEntry = false,
        console = "integratedTerminal",
      },
      {
        type = "netcoredbg",
        name = "Attach to .NET Core process",
        request = "attach",
        processId = require("dap.utils").pick_process,
      },
    })

    -----------------------------------------------------
    -- Keymaps
    -----------------------------------------------------
    local map = vim.keymap.set
    map("n", "<F5>", function()
      dap.continue()
    end, { desc = "DAP continue" })
    map("n", "<F10>", function()
      dap.step_over()
    end, { desc = "DAP step over" })
    map("n", "<F11>", function()
      dap.step_into()
    end, { desc = "DAP step into" })
    map("n", "<F12>", function()
      dap.step_out()
    end, { desc = "DAP step out" })
    map("n", "<leader>db", function()
      dap.toggle_breakpoint()
    end, { desc = "DAP toggle breakpoint" })
    map("n", "<leader>dB", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "DAP conditional breakpoint" })
    map("n", "<leader>dr", function()
      dap.repl.open()
    end, { desc = "DAP open REPL" })
    map("n", "<leader>dl", function()
      dap.run_last()
    end, { desc = "DAP run last" })
    map("n", "<leader>du", function()
      dapui.toggle()
    end, { desc = "DAP toggle UI" })
  end,
}
