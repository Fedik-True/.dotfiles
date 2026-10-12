-- Options are automatically loaded before lazy.nvim startup, and *before* the
-- plugin spec is parsed -- which is why the `vim.g.lazyvim_*` switches below work.
-- Defaults that LazyVim already sets are intentionally not repeated here.
-- Default LazyVim options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- ── LazyVim feature selection ───────────────────────────────────────────────
-- These make LazyVim auto-import `extras.editor.telescope` and `extras.coding.blink`.
vim.g.lazyvim_picker = "telescope"
vim.g.lazyvim_cmp = "blink.cmp"
-- Only run Prettier when the project actually ships a Prettier config.
vim.g.lazyvim_prettier_needs_config = true

-- ── Providers ───────────────────────────────────────────────────────────────
-- Use the native ARM64 CPython for the :python3 provider. The x64 3.12 install
-- earlier on $PATH would otherwise be picked and run under emulation.
local arm64_python = vim.fs.normalize("~/AppData/Local/Programs/Python/Python313-arm64/python.exe")
if vim.uv.fs_stat(arm64_python) then
  vim.g.python3_host_prog = arm64_python
end
-- Nothing in this config is a Perl or Ruby remote plugin.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- ── Shell ───────────────────────────────────────────────────────────────────
-- Drives `:terminal`, `:!`, `:make` and the Snacks terminal helpers.
--
-- Setting this explicitly matters on Windows: Neovim honours $SHELL even here,
-- so launching from Git Bash would otherwise pair bash with the Windows default
-- 'shellcmdflag' (/s /c). Every shell-out then fails with
-- "/usr/bin/bash: /s: No such file or directory", which silently breaks
-- healthchecks and any plugin that calls system().
do
  -- LazyVim's helper sets 'shell' plus the matching shellcmdflag/redir/pipe.
  LazyVim.terminal.setup("pwsh")

  -- Guard the degraded case. The helper only checks executable("pwsh"), which
  -- fails when the PowerShell 7 package directory is not on the inherited $PATH
  -- (Store installs expose pwsh.exe as a 0-byte app-execution alias). It then
  -- falls back to Windows PowerShell 5.1 while still emitting pwsh-7-only syntax
  -- -- $PSStyle and Remove-Alias -- so every system() call errors out.
  --
  -- (Pointing 'shell' straight at the Store app-execution alias was tried and
  -- rejected: it makes Neovim hang during startup.)
  if vim.o.shell ~= "pwsh" then
    if vim.fn.executable("powershell") == 1 then
      -- Windows PowerShell 5.1 with 5.1-safe flags.
      vim.o.shell = "powershell"
      vim.o.shellcmdflag = table.concat({
        "-NoLogo",
        "-NoProfile",
        "-ExecutionPolicy",
        "RemoteSigned",
        "-Command",
        "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();",
        "$PSDefaultParameterValues['Out-File:Encoding']='utf8';",
      }, " ")
      vim.o.shellredir = "> %s 2>&1"
      vim.o.shellpipe = "> %s 2>&1"
      vim.o.shellquote = ""
      vim.o.shellxquote = ""
    else
      -- Coherent cmd.exe defaults -- never an inherited POSIX $SHELL.
      vim.o.shell = vim.env.COMSPEC or "cmd.exe"
      vim.o.shellcmdflag = "/s /c"
      vim.o.shellredir = ">%s 2>&1"
      vim.o.shellpipe = ">%s 2>&1"
      vim.o.shellquote = ""
      vim.o.shellxquote = '"'
    end
  end
end

-- ── Editor ──────────────────────────────────────────────────────────────────
vim.opt.title = true
vim.opt.cmdheight = 0 -- noice.nvim renders the cmdline
vim.opt.scrolloff = 10
vim.opt.breakindent = true
vim.opt.inccommand = "split"
vim.opt.splitkeep = "cursor"
vim.opt.mouse = "" -- keyboard-only, deliberately

-- Search down into subfolders for `:find` / `gf`, but never into node_modules.
vim.opt.path:append({ "**" })
vim.opt.wildignore:append({ "*/node_modules/*" })

-- Continue block comments on <CR>/o. `<leader>o` / `<leader>O` opt out per-line.
vim.opt.formatoptions:append({ "r" })

-- ── Filetypes ───────────────────────────────────────────────────────────────
-- Neovim has no built-in .mdx detection; the treesitter spec registers mdx as
-- markdown so it gets real highlighting.
vim.filetype.add({
  extension = {
    mdx = "mdx",
  },
  pattern = {
    [".*/templates/.*%.html"] = "htmldjango",
  },
})
