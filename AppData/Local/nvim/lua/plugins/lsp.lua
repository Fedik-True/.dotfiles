local python_markers = {
  "pyrightconfig.json",
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  ".git",
}

local function local_python(dir)
  for _, name in ipairs({ ".venv", "venv" }) do
    local python = vim.fs.joinpath(dir, name, "Scripts", "python.exe")
    if vim.uv.fs_stat(python) then
      return python
    end
  end
end

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

        pyright = {
          root_dir = function(bufnr, on_dir)
            local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
            while dir do
              if local_python(dir) then
                on_dir(dir)
                return
              end
              for _, marker in ipairs(python_markers) do
                if vim.uv.fs_stat(vim.fs.joinpath(dir, marker)) then
                  on_dir(dir)
                  return
                end
              end
              local parent = vim.fs.dirname(dir)
              if parent == dir then
                break
              end
              dir = parent
            end
            on_dir(vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
          end,
          before_init = function(_, config)
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            if
              not config.settings.python.pythonPath
              and config.root_dir
              and not vim.uv.fs_stat(vim.fs.joinpath(config.root_dir, "pyrightconfig.json"))
            then
              config.settings.python.pythonPath = local_python(config.root_dir)
            end
          end,
        },

        -- tailwindcss / vtsls / eslint / jsonls / yamlls / ruff all come
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
