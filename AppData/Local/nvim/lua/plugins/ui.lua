return {
  -- ── Messages, cmdline and popupmenu ───────────────────────────────────────
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      -- Drop the noisy "No information available" hover notifications.
      table.insert(opts.routes, {
        filter = { event = "notify", find = "No information available" },
        opts = { skip = true },
      })

      -- While Neovim is unfocused, mirror notifications to the OS.
      local focused = true
      local group = vim.api.nvim_create_augroup("elysium_noice_focus", { clear = true })
      vim.api.nvim_create_autocmd("FocusGained", {
        group = group,
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        group = group,
        callback = function()
          focused = false
        end,
      })
      table.insert(opts.routes, 1, {
        filter = {
          cond = function()
            return not focused
          end,
        },
        view = "notify_send",
        opts = { stop = false },
      })

      -- `:Noice` opens the full history in a split.
      opts.commands = {
        all = {
          view = "split",
          opts = { enter = true, format = "details" },
          filter = {},
        },
      }

      -- Conceal/render markdown keymaps in markdown buffers.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("elysium_noice_markdown", { clear = true }),
        pattern = "markdown",
        callback = function(event)
          vim.schedule(function()
            require("noice.text.markdown").keys(event.buf)
          end)
        end,
      })

      opts.presets.lsp_doc_border = true
    end,
  },

  -- ── Snacks ────────────────────────────────────────────────────────────────
  {
    "snacks.nvim",
    opts = {
      -- Smooth scrolling fights WezTerm's Acrylic compositing.
      scroll = { enabled = false },
      -- Single, deterministic owner for vim.ui.*: dressing.nvim, which LazyVim's
      -- `editor.telescope` extra pulls in and which renders `vim.ui.select`
      -- through Telescope. Leaving Snacks.input enabled too would mean two
      -- plugins racing to hook vim.ui.input depending on load order.
      input = { enabled = false },
      image = { enabled = true },

      dashboard = {
        preset = {
          header = [[
  ███████╗██╗  ██╗   ██╗███████╗██╗██╗   ██╗███╗   ███╗██╗   ██╗██╗███╗   ███╗
  ██╔════╝██║  ╚██╗ ██╔╝██╔════╝██║██║   ██║████╗ ████║██║   ██║██║████╗ ████║
  █████╗  ██║   ╚████╔╝ ███████╗██║██║   ██║██╔████╔██║██║   ██║██║██╔████╔██║
  ██╔══╝  ██║    ╚██╔╝  ╚════██║██║██║   ██║██║╚██╔╝██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ███████╗███████╗██║   ███████║██║╚██████╔╝██║ ╚═╝ ██║ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚══════╝╚══════╝╚═╝   ╚══════╝╚═╝ ╚═════╝ ╚═╝     ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
          ]],
        },
      },
    },
  },

  -- ── Bufferline (tab pages, not buffers) ───────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next Tab" },
      { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev Tab" },
    },
    opts = {
      options = {
        mode = "tabs",
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
  },

  -- ── Floating filename per window ──────────────────────────────────────────
  {
    "b0o/incline.nvim",
    dependencies = { "craftzdog/solarized-osaka.nvim" },
    event = "BufReadPre",
    priority = 1200,
    config = function()
      local colors = require("solarized-osaka.colors").setup()
      require("incline").setup({
        highlight = {
          groups = {
            InclineNormal = { guibg = colors.magenta500, guifg = colors.base04 },
            InclineNormalNC = { guifg = colors.violet500, guibg = colors.base03 },
          },
        },
        window = { margin = { vertical = 0, horizontal = 1 } },
        hide = { cursorline = true },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end
          if vim.bo[props.buf].modified then
            filename = "[+] " .. filename
          end
          -- mini.icons provides the nvim-web-devicons shim via package.preload.
          local icon, color = require("nvim-web-devicons").get_icon_color(filename)
          return { { icon, guifg = color }, { " " }, { filename } }
        end,
      })
    end,
  },

  -- ── Statusline ────────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Index 4 of lualine_c is LazyVim's pretty_path component.
      opts.sections.lualine_c[4] = {
        LazyVim.lualine.pretty_path({
          length = 0,
          relative = "cwd",
          modified_hl = "MatchParen",
          directory_hl = "",
          filename_hl = "Bold",
          modified_sign = "",
          readonly_icon = " 󰌾 ",
        }),
      }
    end,
  },

  -- ── Distraction-free writing ──────────────────────────────────────────────
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      plugins = { gitsigns = true },
    },
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } },
  },
}
