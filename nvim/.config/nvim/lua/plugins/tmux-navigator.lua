return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", mode = { "n", "t" } },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", mode = { "n", "t" } },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", mode = { "n", "t" } },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", mode = { "n", "t" } },
    },
  },

  -- Override LazyVim's snacks terminal nav keys that conflict
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          keys = {
            nav_h = { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate Left", mode = "t" },
            nav_j = { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate Down", mode = "t" },
            nav_k = { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate Up", mode = "t" },
            nav_l = { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate Right", mode = "t" },
          },
        },
      },
    },
  },
}
