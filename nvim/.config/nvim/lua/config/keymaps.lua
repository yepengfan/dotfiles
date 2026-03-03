-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Zellij helpers for Claude Code pane (assumed to the right of Neovim)
local function zellij(args)
  vim.fn.system(vim.list_extend({ "zellij", "action" }, args))
end

local function focus_claude()
  zellij({ "move-focus", "right" })
end

local function focus_neovim()
  zellij({ "move-focus", "left" })
end

local function write_chars(text)
  zellij({ "write-chars", text })
end

local function send_to_claude(text)
  focus_claude()
  vim.defer_fn(function()
    write_chars(text)
    focus_neovim()
  end, 50)
end

-- Focus Claude pane
vim.keymap.set("n", "<leader>af", focus_claude, { desc = "Focus Claude pane" })

-- Send file:line reference
vim.keymap.set("n", "<leader>ar", function()
  local ref = vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")
  send_to_claude(ref)
end, { desc = "Send file:line ref" })

-- Send file path
vim.keymap.set("n", "<leader>ab", function()
  send_to_claude(vim.fn.expand("%:."))
end, { desc = "Send file path" })

-- Send visual selection with context
vim.keymap.set("v", "<leader>as", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local path = vim.fn.expand("%:.")
  local header = path .. ":" .. start_line .. "-" .. end_line
  local text = header .. "\n```\n" .. table.concat(lines, "\n") .. "\n```"
  send_to_claude(text)
end, { desc = "Send selection to Claude" })
