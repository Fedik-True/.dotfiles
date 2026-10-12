return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.keymap.preset = "default" -- No Enter acceptance; Ctrl+Y remains explicit.
      opts.keymap["<C-y>"] = { "select_and_accept" }
      opts.keymap["<C-e>"] = { "hide", "fallback" }
      opts.completion.list = opts.completion.list or {}
      opts.completion.list.selection = { preselect = false, auto_insert = false }
      opts.enabled = function()
        return vim.g.auto_completion_enabled ~= false
      end
    end,
  },

  {
    "nvim-mini/mini.pairs",
    config = function(_, opts)
      LazyVim.mini.pairs(opts)
      local pairs = require("mini.pairs")
      local open = pairs.open
      pairs.open = function(pair, neigh_pattern)
        if (pair == '""' or pair == "''") and vim.bo.filetype == "python" then
          local cursor = vim.api.nvim_win_get_cursor(0)
          local before = vim.api.nvim_get_current_line():sub(1, cursor[2])
          if before:sub(-2) == pair then
            return pair:sub(1, 1) -- Third quote of a triple-quoted string, even before Tree-sitter catches up.
          end
        end
        return open(pair, neigh_pattern)
      end
    end,
  },
}
