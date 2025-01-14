-- lua/plugins.lua

-- Function to load plugins from a specified folder
local function load_plugins_from_folder(folder)
  local path = vim.fn.stdpath "config" .. "/lua/" .. folder
  local plugin_files = vim.fn.readdir(path, [[v:val =~ '\.lua$']])

  local plugins = {}
  for _, file in ipairs(plugin_files) do
    local plugin = folder:gsub("/", ".") .. "." .. file:gsub("%.lua$", "")
    table.insert(plugins, require(plugin))
  end
  return plugins
end

-- Load main plugins
local main_plugins = load_plugins_from_folder "plugins"

-- Load extra plugins
local extra_plugins = load_plugins_from_folder "plugins/extras"

-- Combine and return all plugins
return vim.tbl_extend("force", main_plugins, extra_plugins)
