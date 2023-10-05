local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local action_state = require("telescope.actions.state")

local conf = require("telescope.config").values


local function action(recipe)
  vim.cmd("!just " .. recipe.name)
end

local function trim(s)
  return s:gsub("^%s*(.-)%s*$", "%1")
end

local function parse_line(line)
  local name, description = line:match("^(.-)#(.*)$")
  if name == nil and line ~= nil then
    -- if there is no description, just return as is
    line = trim(line) or line
    line = line:gsub(" .*", "") or line
    return line, "no desc"
  end
  name = trim(name) or name
  name = name:gsub(" .*", "") or name
  return name, trim(description)
end

local function get_recipes()
  local recipes = {}
  local handle = io.popen("just --list --list-heading ''")

  if handle == nil then
    print("Failed to run just!")
    return recipes
  end

  for line in handle:lines() do
    local name, description = parse_line(line)
    if name ~= nil and description ~= nil then
      recipes[name] = {name = name, description = description}
    end
  end
  handle:close()
  return recipes
end

local function search(opts)
  local recipes = get_recipes()

  local results = {}
  for name, recipe in pairs(recipes) do
    table.insert(results, {
      value = recipe,
      ordinal = name,
      display = name,
    })
  end

  pickers.new(opts, {
    prompt_title = "Just",
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return {
          value = entry.value,
          ordinal = entry.ordinal,
          display = entry.display,
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry(prompt_bufnr)
        actions.close(prompt_bufnr)

        action(selection.value)
      end)

      return true
    end,
  }):find()
end

return require("telescope").register_extension {
  setup = function(_)
    action = action
  end,
  exports = {
    just = search,
  },
}
