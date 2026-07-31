local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = ".NET DAP" })
end

local launch_state = {}

local function read_file(path)
  if vim.fn.filereadable(path) == 0 then
    return nil
  end

  return table.concat(vim.fn.readfile(path), "\n")
end

local function parse_csproj(path)
  local content = read_file(path)
  if not content then
    return nil
  end

  local assembly_name = content:match("<AssemblyName>(.-)</AssemblyName>")
    or vim.fs.basename(path):gsub("%.csproj$", "")
  local output_type = content:match("<OutputType>(.-)</OutputType>")
  local sdk = content:match('<Project%s+Sdk="(.-)"')
  local is_runnable = output_type == "Exe"
    or sdk == "Microsoft.NET.Sdk.Web"
    or (sdk and sdk:match("^Aspire%.AppHost%.Sdk"))

  return {
    assembly_name = assembly_name,
    is_runnable = is_runnable,
    path = path,
    project_dir = vim.fs.dirname(path),
  }
end

local function find_nearest_csproj(start_dir, root_dir)
  local matches = vim.fs.find(function(name)
    return name:match("%.csproj$")
  end, {
    path = start_dir,
    stop = root_dir,
    type = "file",
    upward = true,
  })

  return matches[1]
end

local function collect_projects(root_dir)
  local csprojs = vim.fs.find(function(name)
    return name:match("%.csproj$")
  end, {
    path = root_dir,
    type = "file",
    limit = math.huge,
  })

  table.sort(csprojs)

  local projects = {}
  for _, path in ipairs(csprojs) do
    local project = parse_csproj(path)
    if project and project.is_runnable then
      projects[#projects + 1] = project
    end
  end

  return projects
end

local function to_relative_path(root_dir, path)
  local prefix = root_dir:gsub("([^%w])", "%%%1")
  return path:gsub("^" .. prefix .. "/?", "")
end

local function select_project(projects, root_dir)
  if #projects == 0 then
    error(("No runnable .NET projects found under %s"):format(root_dir))
  end

  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file ~= "" then
    local nearest = find_nearest_csproj(vim.fs.dirname(current_file), root_dir)
    if nearest then
      for _, project in ipairs(projects) do
        if project.path == nearest then
          return project
        end
      end
    end
  end

  if #projects == 1 then
    return projects[1]
  end

  local current_coroutine = coroutine.running()
  assert(current_coroutine, "Project selection must run inside the DAP coroutine")

  vim.ui.select(projects, {
    prompt = "Select a .NET project to debug:",
    format_item = function(project)
      return to_relative_path(root_dir, project.path)
    end,
  }, function(project)
    vim.schedule(function()
      local ok, err = coroutine.resume(current_coroutine, project)
      if not ok then
        notify(err, vim.log.levels.ERROR)
      end
    end)
  end)

  local project = coroutine.yield()
  if not project then
    error("Debug launch cancelled: no .NET project selected")
  end

  return project
end

local function resolve_root_dir()
  local current_file = vim.api.nvim_buf_get_name(0)
  local start_dir = current_file ~= "" and vim.fs.dirname(current_file) or vim.fn.getcwd()
  local markers = vim.fs.find(function(name)
    return name == "Directory.Build.props"
      or name == "Directory.Packages.props"
      or name == "global.json"
      or name == ".git"
      or name:match("%.sln$")
  end, {
    path = start_dir,
    stop = vim.uv.os_homedir(),
    upward = true,
    limit = math.huge,
  })

  if #markers > 0 then
    table.sort(markers, function(left, right)
      return #left > #right
    end)
    return vim.fs.dirname(markers[1])
  end

  return vim.fn.getcwd()
end

local function current_launch_key()
  return table.concat({
    resolve_root_dir(),
    vim.api.nvim_buf_get_name(0),
  }, "::")
end

local function pick_profile_name(profiles)
  local names = vim.tbl_keys(profiles)
  table.sort(names)

  for _, preferred in ipairs({ "https", "http" }) do
    if profiles[preferred] and profiles[preferred].commandName == "Project" then
      return preferred
    end
  end

  for _, name in ipairs(names) do
    if profiles[name].commandName == "Project" then
      return name
    end
  end
end

local function load_launch_profile(project)
  local launch_settings_path = vim.fs.joinpath(project.project_dir, "Properties", "launchSettings.json")
  local content = read_file(launch_settings_path)
  if not content then
    return nil, nil
  end

  local ok, launch_settings = pcall(vim.json.decode, content)
  if not ok then
    notify(("Failed to parse %s"):format(launch_settings_path), vim.log.levels.WARN)
    return nil, nil
  end

  local profiles = launch_settings.profiles or {}
  local profile_name = pick_profile_name(profiles)
  if not profile_name then
    return nil, nil
  end

  return profile_name, profiles[profile_name]
end

local function find_program_path(project)
  local target_path = vim
    .system({
      "dotnet",
      "msbuild",
      project.path,
      "-nologo",
      "-getProperty:TargetPath",
      "-property:Configuration=Debug",
    }, {
      cwd = project.project_dir,
      text = true,
    })
    :wait()

  if target_path.code == 0 then
    local program = vim.trim(target_path.stdout or "")
    if program ~= "" and vim.fn.filereadable(program) == 1 then
      return program
    end
  end

  local dll_name = ("%s.dll"):format(project.assembly_name)
  local matches = vim.fs.find(function(name)
    return name == dll_name
  end, {
    path = vim.fs.joinpath(project.project_dir, "bin"),
    type = "file",
    limit = math.huge,
  })

  table.sort(matches, function(left, right)
    local left_debug = left:find("/Debug/", 1, true) ~= nil
    local right_debug = right:find("/Debug/", 1, true) ~= nil
    if left_debug ~= right_debug then
      return left_debug
    end
    return left < right
  end)

  return matches[1]
end

local function build_project(project, fallback_program)
  notify(("Building %s"):format(vim.fs.basename(project.path)))

  local result = vim
    .system({ "dotnet", "build", project.path, "-c", "Debug", "-nologo" }, {
      cwd = project.project_dir,
      text = true,
    })
    :wait()

  if result.code == 0 then
    return true
  end

  if fallback_program then
    notify("dotnet build failed, using existing build output", vim.log.levels.WARN)
    return false
  end

  local output = vim.trim(table.concat({
    result.stdout or "",
    result.stderr or "",
  }, "\n"))

  error(output ~= "" and output or ("dotnet build failed for %s"):format(project.path))
end

local function find_netcoredbg()
  local registry_ok, registry = pcall(require, "mason-registry")
  if registry_ok then
    local package_ok, package = pcall(registry.get_package, "netcoredbg")
    if package_ok and package:is_installed() then
      local mason_binary = vim.fs.joinpath(package:get_install_path(), "netcoredbg")
      if vim.fn.executable(mason_binary) == 1 then
        return mason_binary
      end
    end
  end

  return vim.fn.exepath("netcoredbg")
end

local function resolve_project()
  local key = current_launch_key()
  if launch_state.key == key and launch_state.project then
    return launch_state.project
  end

  local root_dir = resolve_root_dir()
  local projects = collect_projects(root_dir)
  local project = select_project(projects, root_dir)
  launch_state = { key = key, project = project }
  return project
end

local function resolve_launch_configuration()
  local project = resolve_project()
  local existing_program = find_program_path(project)
  build_project(project, existing_program)

  local program = find_program_path(project) or existing_program
  if not program then
    error(("Unable to find debug output for %s"):format(project.path))
  end

  local profile_name, profile = load_launch_profile(project)
  local args = {}
  local env = {}

  if profile then
    if profile.commandLineArgs and profile.commandLineArgs ~= "" then
      args = require("dap.utils").splitstr(profile.commandLineArgs)
    end

    for key, value in pairs(profile.environmentVariables or {}) do
      env[key] = value
    end

    if profile.applicationUrl and env.ASPNETCORE_URLS == nil then
      env.ASPNETCORE_URLS = profile.applicationUrl
    end

    if profile_name then
      env.DOTNET_LAUNCH_PROFILE = profile_name
    end
  end

  return {
    name = ".NET Launch",
    type = "coreclr",
    request = "launch",
    program = program,
    cwd = project.project_dir,
    env = env,
    args = args,
    stopAtEntry = false,
  }
end

local function new_launch_configuration()
  return setmetatable({
    name = ".NET Launch",
    type = "coreclr",
    request = "launch",
  }, {
    __call = resolve_launch_configuration,
  })
end

local function select_process()
  return require("dap.utils").pick_process({
    prompt = "Select a .NET process:",
    filter = function(process)
      local name = process.name
      local is_dotnet = name:find("dotnet", 1, true)
        or name:find(".dll", 1, true)
        or name:find("/artifacts/bin/", 1, true)
        or name:find("/bin/Debug/", 1, true)
        or name:find("/bin/Release/", 1, true)

      return is_dotnet
        and not name:find("OmniSharp", 1, true)
        and not name:find("MSBuild.dll", 1, true)
        and not name:find("netcoredbg", 1, true)
    end,
  })
end

local function setup_dap()
  local ok, dap = pcall(require, "dap")
  if not ok then
    return
  end

  local netcoredbg = find_netcoredbg()
  if netcoredbg == nil or netcoredbg == "" then
    notify("netcoredbg is not installed or not on PATH", vim.log.levels.WARN)
    return
  end

  dap.adapters.coreclr = {
    type = "executable",
    command = netcoredbg,
    args = { "--interpreter=vscode" },
  }
  dap.adapters.netcoredbg = dap.adapters.coreclr

  local attach_configuration = {
    name = ".NET Attach",
    type = "coreclr",
    request = "attach",
    processId = select_process,
  }

  for _, language in ipairs({ "cs", "fsharp", "vb" }) do
    dap.configurations[language] = {
      new_launch_configuration(),
      vim.deepcopy(attach_configuration),
    }
  end
end

return {
  { "Hoffs/omnisharp-extended-lsp.nvim" },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "c_sharp" } },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "csharpier", "netcoredbg", "omnisharp" } },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    init = function()
      vim.schedule(setup_dap)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "Hoffs/omnisharp-extended-lsp.nvim" },
    opts = function(_, opts)
      local dotnet_root = vim.env.DOTNET_ROOT or (vim.fn.expand("~/.dotnet"))
      local path = vim.env.PATH or ""

      opts.servers = opts.servers or {}
      opts.servers.omnisharp = {
        cmd_env = {
          DOTNET_ROOT = dotnet_root,
          PATH = dotnet_root .. ":" .. path,
        },
        handlers = {
          ["textDocument/definition"] = function(...)
            return require("omnisharp_extended").handler(...)
          end,
        },
        keys = {
          {
            "gd",
            function()
              local omnisharp = require("omnisharp_extended")
              if LazyVim.has("telescope.nvim") then
                return omnisharp.telescope_lsp_definitions()
              end
              return omnisharp.lsp_definitions()
            end,
            desc = "Goto Definition",
            has = "definition",
          },
        },
        settings = {
          FormattingOptions = {
            OrganizeImports = true,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableImportCompletion = true,
          },
        },
      }
    end,
  },
  {
    "Issafalcon/neotest-dotnet",
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.csharpier)
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "Issafalcon/neotest-dotnet",
    },
    opts = {
      adapters = {
        ["neotest-dotnet"] = {},
      },
    },
  },
}
