-- Keymaps are automatically loaded on the VeryLazy event -- i.e. *after* lazy.nvim
-- has installed its lazy-loading `keys` handlers. Anything mapped here therefore
-- wins over a plugin's `keys` spec, so only map what no plugin already owns.
-- Default LazyVim keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
--
-- Deliberately NOT mapped here, because LazyVim already provides them:
--   diagnostics  -> `]d` / `[d`         inlay hints -> `<leader>uh`
--   terminal     -> `<C-/>`, `<leader>ft`   autoformat  -> `<leader>uf` / `<leader>uF`
--   new tab      -> `<leader><tab><tab>`    zoom/zen    -> `<leader>uZ` / `<leader>uz`
--   window nav   -> `<C-h/j/k/l>`

local map = vim.keymap.set

-- ── Black-hole register ("void") ────────────────────────────────────────────
-- Delete/change without clobbering the unnamed register. These used to live on
-- `<leader>c` / `<leader>d`, which shadowed LazyVim's entire `code` and `debug`
-- namespaces, so they now sit under the free `<leader>v` prefix.
map("n", "x", '"_x', { desc = "Delete char (void)" })
map({ "n", "v" }, "<leader>vd", '"_d', { desc = "Delete (void)" })
map({ "n", "v" }, "<leader>vD", '"_D', { desc = "Delete to EOL (void)" })
map({ "n", "v" }, "<leader>vc", '"_c', { desc = "Change (void)" })
map({ "n", "v" }, "<leader>vC", '"_C', { desc = "Change to EOL (void)" })
map("x", "<leader>vp", '"_dP', { desc = "Paste over selection (keep register)" })

-- Paste the last *yank* rather than the last delete.
map({ "n", "v" }, "<leader>p", '"0p', { desc = "Paste last yank after" })
map("n", "<leader>P", '"0P', { desc = "Paste last yank before" })

-- ── Editing ─────────────────────────────────────────────────────────────────
-- Open a line without carrying the comment leader over ('formatoptions' has "r").
map("n", "<leader>o", "o<Esc>^Da", { desc = "New line below (no comment leader)" })
map("n", "<leader>O", "O<Esc>^Da", { desc = "New line above (no comment leader)" })
map("n", "<leader>A", "gg<S-v>G", { desc = "Select All" })

-- ── Windows ─────────────────────────────────────────────────────────────────
-- `s` is free as a prefix because flash.nvim is disabled in plugins/editor.lua.
-- Plain `s` (substitute) is deliberately shadowed -- use `cl` instead.
map("n", "ss", "<cmd>split<cr>", { desc = "Split window below", silent = true })
map("n", "sv", "<cmd>vsplit<cr>", { desc = "Split window right", silent = true })
map("n", "sh", "<C-w>h", { desc = "Go to left window" })
map("n", "sj", "<C-w>j", { desc = "Go to lower window" })
map("n", "sk", "<C-w>k", { desc = "Go to upper window" })
map("n", "sl", "<C-w>l", { desc = "Go to right window" })

map("n", "<C-w><left>", "<C-w><", { desc = "Decrease window width" })
map("n", "<C-w><right>", "<C-w>>", { desc = "Increase window width" })
map("n", "<C-w><up>", "<C-w>+", { desc = "Increase window height" })
map("n", "<C-w><down>", "<C-w>-", { desc = "Decrease window height" })

-- ── Terminal ────────────────────────────────────────────────────────────────
-- Snacks' own terminals bind this per-window, but a plain `:terminal` has no
-- escape hatch. Double-Esc keeps a single <Esc> deliverable to the program
-- running inside the terminal (vim, htop, fzf, ...).
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Enter Normal Mode" })

-- ── Colors ──────────────────────────────────────────────────────────────────
map("n", "<leader>r", function()
  require("util.hsl").replace_hex_with_hsl()
end, { desc = "Replace hex with HSL on this line" })
