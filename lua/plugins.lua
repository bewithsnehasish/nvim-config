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
local all_plugins = {}
vim.list_extend(all_plugins, main_plugins)
vim.list_extend(all_plugins, extra_plugins)
return all_plugins
