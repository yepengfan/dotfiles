-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Force redraw when switching to/from terminal buffers (fixes garbled text
-- and blank content in Claude Code terminal after navigating between splits)
local terminal_redraw = vim.api.nvim_create_augroup("terminal_redraw", { clear = true })

vim.api.nvim_create_autocmd({ "TermEnter", "BufEnter" }, {
  group = terminal_redraw,
  pattern = "term://*",
  callback = function()
    vim.schedule(function()
      vim.cmd("mode")
    end)
  end,
})

vim.api.nvim_create_autocmd("TermLeave", {
  group = terminal_redraw,
  pattern = "term://*",
  callback = function()
    vim.schedule(function()
      vim.cmd("mode")
    end)
  end,
})
