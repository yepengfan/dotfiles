return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },

  opts = {
    terminal = {
      split_side = "right",
      split_width_percentage = 0.35,
      provider = "snacks",
      snacks_win_opts = {
        keys = {
          nav_h = { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Navigate Left", mode = "t" },
          nav_j = { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Navigate Down", mode = "t" },
          nav_k = { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Navigate Up", mode = "t" },
          nav_l = { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Navigate Right", mode = "t" },
        },
      },
    },
    track_selection = true,
  },

  keys = {
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer to Claude" },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject diff" },
  },
}
