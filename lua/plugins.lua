local function is_non_empty_spec(spec)
  if type(spec) ~= "table" then
    return false
  end

  if vim.islist(spec) then
    return #spec > 0
  end

  return next(spec) ~= nil
end

local function load_plugins_from_folder(folder, allowed_files)
  local path = vim.fn.stdpath "config" .. "/lua/" .. folder
  local plugin_files = vim.fn.readdir(path, [[v:val =~ '\.lua$']])
  table.sort(plugin_files)

  local plugins = {}
  for _, file in ipairs(plugin_files) do
    local module_name = file:gsub("%.lua$", "")
    if not allowed_files or allowed_files[module_name] then
      local plugin = folder:gsub("/", ".") .. "." .. module_name
      local ok, spec = pcall(require, plugin)

      if ok and is_non_empty_spec(spec) then
        table.insert(plugins, spec)
      elseif not ok then
        vim.notify("Failed to load plugin spec: " .. plugin .. "\n" .. tostring(spec), vim.log.levels.ERROR)
      end
    end
  end

  return plugins
end

local enabled_extra_plugins = {}
for _, name in ipairs(vim.g.enabled_extra_plugins or {}) do
  enabled_extra_plugins[name] = true
end

local main_plugins = load_plugins_from_folder "plugins"
local extra_plugins = load_plugins_from_folder("plugins/extras", enabled_extra_plugins)

local all_plugins = {}
vim.list_extend(all_plugins, main_plugins)
vim.list_extend(all_plugins, extra_plugins)

return all_plugins
