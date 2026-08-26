return {
  -- `s` is used as a window/split prefix in config/keymaps.lua.
  { "folke/flash.nvim", enabled = false },

  -- Inline colour swatches. Replaces LazyVim's `util.mini-hipatterns` extra,
  -- which only handles plain hex -- this also does rgb()/hsl()/css vars and
  -- Tailwind class names, which matters with tailwindcss-language-server.
  {
    "brenoprata10/nvim-highlight-colors",
    event = "BufReadPre",
    opts = {
      render = "background",
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_hsl_without_function = true,
      enable_ansi = true,
      enable_var_usage = true,
      enable_tailwind = true,
    },
  },

  -- Name the custom prefixes so which-key documents them.
  -- LazyVim declares `opts_extend = { "spec" }`, so this appends.
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>v", group = "void (black-hole register)", mode = { "n", "v" } },
        { "s", group = "split/window" },
        { ";", group = "telescope" },
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        -- CMake rather than make: there is no make on this machine, and CMake
        -- picks the native ARM64 MSVC toolchain for libfzf.dll.
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install",
      },
      "nvim-telescope/telescope-file-browser.nvim",
    },
    -- stylua: ignore
    keys = {
      { ";f", function() require("telescope.builtin").find_files({ no_ignore = false, hidden = true }) end, desc = "Find Files (hidden)" },
      { ";r", function() require("telescope.builtin").live_grep({ additional_args = { "--hidden" } }) end, desc = "Live Grep (hidden)" },
      { ";t", function() require("telescope.builtin").help_tags() end, desc = "Help Tags" },
      { ";;", function() require("telescope.builtin").resume() end, desc = "Resume Last Picker" },
      { ";e", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics" },
      { ";s", function() require("telescope.builtin").treesitter() end, desc = "Treesitter Symbols" },
      { ";c", function() require("telescope.builtin").lsp_incoming_calls() end, desc = "LSP Incoming Calls" },
      { "\\\\", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
      { "<leader>fP", function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end, desc = "Find Plugin File" },
      {
        "sf",
        function()
          require("telescope").extensions.file_browser.file_browser({
            path = "%:p:h",
            cwd = vim.fn.expand("%:p:h"),
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "normal",
            layout_config = { height = 40 },
          })
        end,
        desc = "File Browser (buffer dir)",
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = telescope.extensions.file_browser.actions

      -- `opts.defaults` normally comes from LazyVim's `editor.telescope` extra.
      -- Guard it so this file still loads if the picker ever changes.
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        wrap_results = true,
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0, -- WezTerm already composites; blending twice looks muddy
      })
      opts.pickers = vim.tbl_deep_extend("force", opts.pickers or {}, {
        diagnostics = {
          theme = "ivy",
          initial_mode = "normal",
          layout_config = { preview_cutoff = 9999 },
        },
      })
      opts.extensions = vim.tbl_deep_extend("force", opts.extensions or {}, {
        file_browser = {
          theme = "dropdown",
          hijack_netrw = true,
          mappings = {
            ["n"] = {
              ["N"] = fb_actions.create,
              ["h"] = fb_actions.goto_parent_dir,
              ["/"] = function()
                vim.cmd("startinsert")
              end,
              ["<C-u>"] = function(prompt_bufnr)
                for _ = 1, 10 do
                  actions.move_selection_previous(prompt_bufnr)
                end
              end,
              ["<C-d>"] = function(prompt_bufnr)
                for _ = 1, 10 do
                  actions.move_selection_next(prompt_bufnr)
                end
              end,
              ["<PageUp>"] = actions.preview_scrolling_up,
              ["<PageDown>"] = actions.preview_scrolling_down,
            },
          },
        },
      })

      telescope.setup(opts)
      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")
    end,
  },

  {
    "saghen/blink.cmp",
    opts = {
      completion = { menu = { winblend = vim.o.pumblend } },
      signature = { window = { winblend = vim.o.pumblend } },
    },
  },
}
