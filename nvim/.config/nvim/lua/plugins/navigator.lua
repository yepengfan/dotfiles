return {
  -- Disable vim-tmux-navigator (replaced by smart-splits)
  { "christoomey/vim-tmux-navigator", enabled = false },

  -- Smart splits: seamless navigation across Neovim splits and multiplexer panes
  -- Auto-detects tmux, zellij, wezterm, kitty
  {
    "mrjones2014/smart-splits.nvim",
    keys = {
      -- Navigation: Ctrl+hjkl
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Navigate Left", mode = { "n", "t" } },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Navigate Down", mode = { "n", "t" } },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Navigate Up", mode = { "n", "t" } },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Navigate Right", mode = { "n", "t" } },
      -- Resize: Alt+hjkl
      { "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize Left", mode = { "n", "t" } },
      { "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize Down", mode = { "n", "t" } },
      { "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize Up", mode = { "n", "t" } },
      { "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize Right", mode = { "n", "t" } },
    },
  },

  -- Override LazyVim's snacks terminal nav keys that conflict
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          keys = {
            nav_h = { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Navigate Left", mode = "t" },
            nav_j = { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Navigate Down", mode = "t" },
            nav_k = { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Navigate Up", mode = "t" },
            nav_l = { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Navigate Right", mode = "t" },
          },
        },
      },
    },
  },
}
