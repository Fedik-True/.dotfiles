-- Convert hex colours on the current line to `hsl(h, s, l)`.
-- Conversion formulas adapted from https://github.com/EmmanuelOga/columns

local M = {}

---@param hex string e.g. "#1a2b3c"
---@return number[] rgb components in 0..1
local function hex_to_rgb(hex)
  hex = hex:lower():gsub("^#", "")
  local rgb = {}
  for i = 0, 2 do
    rgb[i + 1] = tonumber(hex:sub(i * 2 + 1, i * 2 + 2), 16) / 255.0
  end
  return rgb
end

---@param r number
---@param g number
---@param b number
---@return number h, number s, number l -- degrees, percent, percent
local function rgb_to_hsl(r, g, b)
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s = 0, 0
  local l = (max + min) / 2

  if max ~= min then
    local d = max - min
    s = l > 0.5 and d / (2 - max - min) or d / (max + min)
    if max == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h * 360, s * 100, l * 100
end

---@param hex string
---@return string
function M.hex_to_hsl(hex)
  local rgb = hex_to_rgb(hex)
  local h, s, l = rgb_to_hsl(rgb[1], rgb[2], rgb[3])
  return string.format("hsl(%d, %d, %d)", math.floor(h + 0.5), math.floor(s + 0.5), math.floor(l + 0.5))
end

function M.replace_hex_with_hsl()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
  if not line then
    return
  end

  local replaced = false
  for hex in line:gmatch("#%x%x%x%x%x%x") do
    line = line:gsub(hex, M.hex_to_hsl(hex), 1)
    replaced = true
  end

  if replaced then
    vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { line })
  else
    vim.notify("No 6-digit hex colour on this line", vim.log.levels.INFO)
  end
end

return M
