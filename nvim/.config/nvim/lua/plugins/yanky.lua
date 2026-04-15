return {
  "gbprod/yanky.nvim",
  keys = {
    -- Override yanky's visual paste to not clobber the register
    { "p", '"_dP', mode = { "x" }, desc = "Paste without clobbering register" },
  },
}
