return {
  -- ── Mason ─────────────────────────────────────────────────────────────────
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- Windows ARM64: upstream publishes no aarch64 build for either tool, so
      -- Mason reports "The current platform is unsupported" and retries on every
      -- start. Both are installed system-wide (official x64 builds, run under
      -- Windows' x64 emulation) and resolved from $PATH instead.
      local unsupported = { stylua = true, shfmt = true }
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return not unsupported[tool]
      end, opts.ensure_installed or {})
    end,
  },

  -- ── LSP servers ───────────────────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Toggle per-buffer with `<leader>uh`.
      inlay_hints = { enabled = false },
      ---@type table<string, lazyvim.lsp.Config|boolean>
      servers = {
        -- Custom keymaps for every server. LazyVim declares
        -- `opts_extend = { "servers.*.keys" }`, so this appends to the defaults
        -- rather than replacing them.
        ["*"] = {
          keys = {
            {
              "gd",
              function()
                -- Unlike LazyVim's default, never reuse an existing window.
                require("telescope.builtin").lsp_definitions({ reuse_win = false })
              end,
              desc = "Goto Definition",
              has = "definition",
            },
          },
        },

        cssls = {},
        html = {},

        -- tailwindcss / vtsls / eslint / jsonls / yamlls / pyright / ruff all come
        -- from the imported LazyVim extras; only real deltas are listed below.

        vtsls = {
          settings = {
            -- The extra already configures `typescript.inlayHints`. JavaScript
            -- gets the more verbose set (migrated from the old `tsserver` block).
            javascript = {
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "all" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = true },
              },
            },
          },
        },

        -- Mason has no win_arm64 build; installed system-wide (Chocolatey).
        lua_ls = {
          mason = false,
          settings = {
            Lua = {
              completion = {
                callSnippet = "Both",
                workspaceWord = true,
              },
              -- stylua (via conform.nvim) owns Lua formatting.
              format = { enable = false },
              type = { castNumberToInteger = true },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                unusedLocalExclude = { "_*" },
              },
            },
          },
        },

        -- Installed with `pip` into the native ARM64 CPython instead of Mason,
        -- whose pypi installer would build against the emulated x64 interpreter.
        ruff = { mason = false },

        -- Installed with `npm -g`: a directory lock on Mason's staging path for
        -- this package cannot be cleared without a reboot. Node is native ARM64,
        -- so the server itself is unaffected.
        yamlls = { mason = false },
      },
    },
  },
}
