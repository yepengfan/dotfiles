return {
  {
    "folke/tokyonight.nvim",
    opts = {
      on_highlights = function(hl, c)
        -- When cursorline is enabled (LazyVim default), Neovim uses
        -- LineNrAbove/LineNrBelow instead of LineNr for non-cursor lines.
        hl.LineNr = { fg = "#a6adc8" }
        hl.LineNrAbove = { fg = "#a6adc8" }
        hl.LineNrBelow = { fg = "#a6adc8" }
        -- Cursor line number (already orange+bold by default, override if desired)
        -- hl.CursorLineNr = { fg = "#a6adc8", bold = true }
      end,
    },
  },
}
