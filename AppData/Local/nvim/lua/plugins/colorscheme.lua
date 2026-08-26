return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = true,
    priority = 1000,
    opts = {
      transparent = true, -- let WezTerm's Acrylic backdrop show through
      style = "vivid",
      vivid_brightness = 0.6,

      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "transparent",
        floats = "transparent",
      },

      ---@param hl table<string, vim.api.keyset.highlight>
      on_highlights = function(hl, _)
        -- Python accent palette.
        --
        -- These are Tree-sitter capture groups, suffixed with `.python` so they
        -- apply to Python buffers only -- Neovim resolves `@x.y.python` before
        -- `@x.y` (see vim/treesitter/highlighter.lua). The rest of the
        -- Solarized Osaka palette is untouched for every other language.
        --
        -- Capture names come from nvim-treesitter's python highlights.scm;
        -- confirm any change with `:Inspect` on a real buffer.
        local py = {
          pink = "#ff7ab2", -- class / type / control-flow keywords
          green = "#a6e3a1", -- class names, annotations
          purple = "#c792ea", -- def / lambda, function names
          teal = "#74c7a5", -- strings and docstrings
          blue = "#82aaff", -- builtins
          orange = "#f78c6c", -- numbers
          amber = "#ff966c", -- True / False / None
          cyan = "#89ddff", -- operators
          muted = "#9baec8", -- comments
        }

        -- keywords
        hl["@keyword.python"] = { fg = py.pink, italic = true }
        hl["@keyword.type.python"] = { fg = py.pink, italic = true } -- `class`, `type`
        hl["@keyword.import.python"] = { fg = py.pink, italic = true }
        hl["@keyword.return.python"] = { fg = py.pink, italic = true }
        hl["@keyword.conditional.python"] = { fg = py.pink, italic = true }
        hl["@keyword.repeat.python"] = { fg = py.pink, italic = true }
        hl["@keyword.exception.python"] = { fg = py.pink, italic = true }
        hl["@keyword.coroutine.python"] = { fg = py.pink, italic = true }
        hl["@keyword.function.python"] = { fg = py.purple, italic = true, bold = true } -- `def`, `lambda`

        -- types and classes
        hl["@type.python"] = { fg = py.green, bold = true } -- class name / annotations
        hl["@type.definition.python"] = { fg = py.green, bold = true }
        hl["@type.builtin.python"] = { fg = py.blue }
        hl["@constructor.python"] = { fg = py.green }

        -- functions
        hl["@function.python"] = { fg = py.purple, bold = true }
        hl["@function.method.python"] = { fg = py.purple, bold = true }
        hl["@function.call.python"] = { fg = py.purple }
        hl["@function.method.call.python"] = { fg = py.purple }
        hl["@function.builtin.python"] = { fg = py.blue }

        -- literals
        hl["@string.python"] = { fg = py.teal }
        hl["@string.documentation.python"] = { fg = py.teal, italic = true }
        hl["@number.python"] = { fg = py.orange }
        hl["@number.float.python"] = { fg = py.orange }
        hl["@boolean.python"] = { fg = py.amber, bold = true }
        hl["@constant.builtin.python"] = { fg = py.amber, bold = true } -- None, Ellipsis

        -- misc
        hl["@variable.builtin.python"] = { fg = py.blue, italic = true } -- self, cls
        hl["@module.builtin.python"] = { fg = py.blue }
        hl["@operator.python"] = { fg = py.cyan }
        hl["@keyword.operator.python"] = { fg = py.cyan, italic = true } -- and/or/not/in/is
        hl["@comment.python"] = { fg = py.muted, italic = true }
      end,
    },
  },
}
