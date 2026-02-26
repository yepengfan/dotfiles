return {
  -- Disable neo-tree, use snacks explorer instead
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },

  -- Configure snacks explorer as persistent sidebar
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            auto_close = false,
            jump = { close = false },
            layout = { preset = "sidebar", preview = false },
          },
        },
      },
    },
  },
}
