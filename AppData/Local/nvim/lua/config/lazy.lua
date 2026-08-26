local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim core. `vim.g.lazyvim_picker` / `vim.g.lazyvim_cmp` in config/options.lua
    -- make LazyVim auto-import the `editor.telescope` and `coding.blink` extras.
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        colorscheme = "solarized-osaka",
        news = {
          lazyvim = true,
          neovim = true,
        },
      },
    },

    -- Languages
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.tailwind" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.yaml" },

    -- Tooling
    { import = "lazyvim.plugins.extras.formatting.prettier" },
    { import = "lazyvim.plugins.extras.linting.eslint" },

    -- Personal overrides
    { import = "plugins" },
  },
  defaults = {
    -- Only LazyVim plugins are lazy-loaded by default; ours load at startup
    -- unless a spec opts in with `event`/`keys`/`cmd`/`ft`.
    lazy = false,
    version = false, -- always use the latest git commit
  },
  checker = { enabled = true, notify = false },
  -- No plugin in this config ships a rockspec that needs building, so neither
  -- luarocks nor hererocks are required. Declaring it keeps `:checkhealth lazy`
  -- honest instead of reporting a missing dependency we never use.
  rocks = { enabled = false },
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin", -- telescope-file-browser hijacks netrw
        "rplugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    custom_keys = {
      ["<localleader>d"] = function(plugin)
        dd(plugin)
      end,
    },
  },
})
