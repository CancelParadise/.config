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
    -- Load launchSettings.json with debug prints
    -----------------------------------------------------
    local function load_launch_settings()
      local json_path = vim.fn.getcwd() .. "/Properties/launchSettings.json"
      print("Checking launchSettings.json path:", json_path)

      -- Check if file exists
      local file_exists = vim.fn.filereadable(json_path) == 1
      print("File exists:", file_exists)

      if not file_exists then
        print("launchSettings.json not found!")
        return {}
      end

      local profiles = {}
      local file_content = vim.fn.readfile(json_path)
      local ok, data = pcall(vim.fn.json_decode, file_content)

      print("JSON parse success:", ok)
      if not ok then
        print("JSON parse error:", data)
        return {}
      end

      if data and data.profiles then
        print("Found profiles:", vim.inspect(vim.tbl_keys(data.profiles)))
        for name, profile in pairs(data.profiles) do
          print("Processing profile:", name)
          -- Include environment variables from the profile
          local config = {
            type = "netcoredbg",
            name = "Launch profile: " .. name,
            request = "launch",
            program = function()
              return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/net8.0/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopAtEntry = false,
            console = "integratedTerminal",
            env = profile.environmentVariables or {}, -- Include environment variables
          }
          table.insert(profiles, config)
        end
      end

      print("Loaded profiles:", vim.inspect(profiles))
      return profiles
    end

    -----------------------------------------------------
    -- Final C# configs with debug prints
    -----------------------------------------------------
    local launch_settings = load_launch_settings()
    local final_configs = vim.list_extend(launch_settings, {
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

    print("Final DAP configurations:", vim.inspect(final_configs))
    dap.configurations.cs = final_configs
    print("DAP for .NET Core configured successfully")

    -----------------------------------------------------
    -- Debug listener to track configuration selection
    -----------------------------------------------------
    dap.listeners.before.launch["debug_config"] = function(config)
      print("Selected configuration:", vim.inspect(config))
    end

    -----------------------------------------------------
    -- Keymaps
    -----------------------------------------------------
    local map = vim.keymap.set
    map("n", "<F5>", function()
      print("Starting debugger...")
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
