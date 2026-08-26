return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- LazyVim owns `branch`, `build` and `config` for the nvim-treesitter *main*
    -- branch: its config function installs missing parsers and wires up
    -- highlighting / indent / folds via a FileType autocmd. Overriding either
    -- silently disables all of that, so we only extend the parser list here
    -- (LazyVim declares `opts_extend = { "ensure_installed" }`).
    --
    -- Parsers are compiled by the `tree-sitter` CLI, which picks up the native
    -- ARM64 MSVC toolchain (Hostarm64\arm64\cl.exe) from the VS Build Tools
    -- install -- do NOT set $CC to the mingw gcc on $PATH: it targets
    -- x86_64-w64-mingw32 and produces parsers this ARM64 Neovim cannot load.
    opts = {
      ensure_installed = {
        -- web / styling (cssls + tailwindcss + prettier are configured)
        "css",
        "scss",
        "graphql",
        -- git tooling (gitsigns, lazygit)
        "git_config",
        "git_rebase",
        "gitcommit",
        "gitignore",
        -- environment
        "dockerfile",
        "ini",
        "powershell",
        "requirements",
      },
    },
    init = function()
      -- `.mdx` is detected as its own filetype in config/options.lua; parse it
      -- with the markdown grammar so it gets real treesitter highlighting.
      vim.treesitter.language.register("markdown", "mdx")
    end,
  },
}
