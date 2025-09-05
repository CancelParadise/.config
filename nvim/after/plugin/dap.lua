-- DAP Configuration for .NET Core
local dap = require("dap")

-- .NET Core debugger configuration
dap.adapters.netcoredbg = {
  type = "executable",
  command = vim.fn.exepath("netcoredbg") ~= "" and vim.fn.exepath("netcoredbg") or "netcoredbg",
  args = { "--interpreter=vscode" },
  options = {
    detached = false,
  },
}

-- Helper function to find .NET projects
local function find_dotnet_project()
  local cwd = vim.fn.getcwd()
  local project_files = vim.fn.globpath(cwd, "**/*.csproj", false, true)
  if #project_files == 0 then
    project_files = vim.fn.globpath(cwd, "**/*.fsproj", false, true)
  end
  if #project_files == 0 then
    project_files = vim.fn.globpath(cwd, "**/*.vbproj", false, true)
  end
  return project_files
end

-- Helper function to build and get output path
local function get_program_path()
  local project_files = find_dotnet_project()
  if #project_files == 0 then
    return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file")
  end
  
  local project_file = project_files[1]
  if #project_files > 1 then
    local choices = { "Select project:" }
    for i, file in ipairs(project_files) do
      table.insert(choices, i .. ". " .. file)
    end
    local choice = vim.fn.inputlist(choices)
    if choice == 0 or choice > #project_files then 
      return nil 
    end
    project_file = project_files[choice]
  end
  
  -- Try to determine the output path
  local project_dir = vim.fn.fnamemodify(project_file, ":h")
  local project_name = vim.fn.fnamemodify(project_file, ":t:r")
  
  -- Common output paths for .NET projects
  local possible_paths = {
    project_dir .. "/bin/Debug/net8.0/" .. project_name .. ".dll",
    project_dir .. "/bin/Debug/net7.0/" .. project_name .. ".dll",
    project_dir .. "/bin/Debug/net6.0/" .. project_name .. ".dll",
    project_dir .. "/bin/Debug/net5.0/" .. project_name .. ".dll",
    project_dir .. "/bin/Debug/netcoreapp3.1/" .. project_name .. ".dll",
  }
  
  for _, path in ipairs(possible_paths) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  
  -- If no built dll found, prompt user
  vim.notify("No built dll found. Please build your project first with 'dotnet build'", vim.log.levels.WARN)
  return vim.fn.input("Path to dll: ", project_dir .. "/bin/Debug/", "file")
end

-- .NET Core debug configurations
dap.configurations.cs = {
  {
    type = "netcoredbg",
    name = "Launch .NET Core (auto-detect)",
    request = "launch",
    program = get_program_path,
    cwd = "${workspaceFolder}",
    stopAtEntry = false,
    console = "integratedTerminal",
  },
  {
    type = "netcoredbg",
    name = "Launch .NET Core (manual)",
    request = "launch",
    program = function()
      return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopAtEntry = false,
    console = "integratedTerminal",
  },
  {
    type = "netcoredbg",
    name = "Attach to .NET Core process",
    request = "attach",
    processId = function()
      return require("dap.utils").pick_process({ filter = "dotnet" })
    end,
  },
}

-- Copy configuration for other .NET languages
dap.configurations.fsharp = dap.configurations.cs
dap.configurations.vb = dap.configurations.cs

-- Set up key mappings
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Start/Continue Debugging' })
vim.keymap.set('n', '<F9>', function() require('dap').toggle_breakpoint() end, { desc = 'Toggle Breakpoint' })
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, { desc = 'Step Over' })
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, { desc = 'Step Into' })
vim.keymap.set('n', '<S-F11>', function() require('dap').step_out() end, { desc = 'Step Out' })
vim.keymap.set('n', '<S-F5>', function() require('dap').terminate() end, { desc = 'Stop Debugging' })

-- Leader-based mappings
vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = 'Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dc', function() require('dap').continue() end, { desc = 'Continue' })
vim.keymap.set('n', '<leader>di', function() require('dap').step_into() end, { desc = 'Step Into' })
vim.keymap.set('n', '<leader>do', function() require('dap').step_out() end, { desc = 'Step Out' })
vim.keymap.set('n', '<leader>dO', function() require('dap').step_over() end, { desc = 'Step Over' })
vim.keymap.set('n', '<leader>dt', function() require('dap').terminate() end, { desc = 'Terminate' })
vim.keymap.set('n', '<leader>dr', function() require('dap').repl.toggle() end, { desc = 'Toggle REPL' })

-- Debug command
vim.api.nvim_create_user_command('DapDebugConfig', function()
  print('DAP Adapters:', vim.inspect(dap.adapters))
  print('DAP Configurations:', vim.inspect(dap.configurations))
end, {})

-- Notify when DAP is configured
vim.notify('DAP for .NET Core configured successfully', vim.log.levels.INFO)
