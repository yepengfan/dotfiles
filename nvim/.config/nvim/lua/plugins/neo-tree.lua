return {
  -- Disable snacks explorer (conflicts with neo-tree)
  { "folke/snacks.nvim", opts = { explorer = { enabled = false } } },

  -- Neo-tree config
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
      source_selector = {
        winbar = true,
      },
    },
  },
}
