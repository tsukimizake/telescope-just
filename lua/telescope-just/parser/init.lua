local M = {}

local function trim(s)
  return s:gsub("^%s*(.-)%s*$", "%1")
end

function M.parse_line(line)
  local name, description = line:match("^(.-)#(.*)$")
  if name == nil and line ~= nil then
    -- if there is no description
    name = line
    description = "no desc"
  end
  name = trim(name) or name
  name = name:gsub(" .*", "") or name
  return name, trim(description)
end

return M
