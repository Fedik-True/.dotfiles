-- Autocmds are automatically loaded on the VeryLazy event
-- Default LazyVim autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- LazyVim sets conceallevel=2. Turn concealing off where it hides real content.
-- Window-local, so it does not leak into other buffers.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("elysium_conceal", { clear = true }),
  pattern = { "json", "jsonc", "json5", "markdown", "mdx" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})
