-- Byte-code cache for Lua modules; must run before anything is required.
vim.loader.enable()

-- `dd(...)` dumps any value through vim.notify (rendered by noice).
-- Also used by lazy.nvim's `<localleader>d` custom key in config/lazy.lua.
_G.dd = function(...)
  require("util.debug").dump(...)
end
vim.print = _G.dd

require("config.lazy")
