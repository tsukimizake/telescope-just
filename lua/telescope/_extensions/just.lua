local actions = require("telescope.actions")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local action_state = require("telescope.actions.state")

local conf = require("telescope.config").values


local function action(recipe)
  vim.cmd("!just " .. recipe.name)
end

local function get_recipes()
  local recipes = {}
  local handle = io.popen("just --list --list-heading ''")

  if handle == nil then
    print("Failed to run just!")
    return recipes
  end

  for line in handle:lines() do
    local name, description = line:match("^(.-)#(.*)$")
    name = name:gsub("^%s*(.-)%s*$", "%1")
    name = name:gsub(" .*", "")
    if (name ~= nil or name ~= "") and description ~= nil then
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
