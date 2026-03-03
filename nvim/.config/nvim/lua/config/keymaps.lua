-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Zellij helpers for Claude Code pane (tiled, to the right of Neovim)
if vim.env.ZELLIJ then
  local function zellij(args)
    vim.fn.system(vim.list_extend({ "zellij", "action" }, args))
  end

  --- Parse dump-layout once and return pane state for the given command.
  --- Returns: exists (bool), focused (bool), is_fullscreen (bool)
  local function pane_state(command)
    local layout = vim.fn.system("zellij action dump-layout")
    local pattern = 'command="' .. vim.pesc(command) .. '"'
    local exists = layout:match(pattern) ~= nil
    local focused = false
    for line in layout:gmatch("[^\n]+") do
      if line:match(pattern) and line:match("focus=true") then
        focused = true
        break
      end
    end
    local is_fullscreen = layout:match("%f[%w]fullscreen true%f[%W]") ~= nil
    return exists, focused, is_fullscreen
  end

  --- Cycle through panes until the focused pane matches the target command.
  --- Exits fullscreen first if needed so all panes are reachable.
  local function focus_pane(command)
    local exists, focused, is_fullscreen = pane_state(command)
    if focused then return true end
    if not exists then
      vim.notify("No " .. command .. " pane found", vim.log.levels.WARN)
      return false
    end
    if is_fullscreen then
      zellij({ "toggle-fullscreen" })
    end
    for _ = 1, 10 do
      zellij({ "focus-next-pane" })
      local _, is_focused = pane_state(command)
      if is_focused then return true end
    end
    vim.notify("Could not focus " .. command .. " pane", vim.log.levels.WARN)
    return false
  end

  local function focus_claude()
    return focus_pane("claude")
  end

  local function focus_neovim()
    return focus_pane("nvim")
  end

  local function write_chars(text)
    zellij({ "write-chars", text })
  end

  --- Focus Claude pane, type text, then return to Neovim.
  --- Restores fullscreen if it was active before sending.
  local function send_to_claude(text)
    local _, _, was_fullscreen = pane_state("claude")
    if not focus_claude() then return end
    write_chars(text)
    focus_neovim()
    if was_fullscreen then
      zellij({ "toggle-fullscreen" })
    end
  end

  local function buf_path()
    local path = vim.fn.expand("%:.")
    if path == "" then
      vim.notify("Buffer has no file", vim.log.levels.WARN)
      return nil
    end
    return path
  end

  -- Focus Claude pane
  vim.keymap.set("n", "<leader>af", focus_claude, { desc = "Focus Claude pane" })

  -- Send file:line reference
  vim.keymap.set("n", "<leader>ar", function()
    local path = buf_path()
    if not path then return end
    send_to_claude(path .. ":" .. vim.fn.line("."))
  end, { desc = "Send file:line ref" })

  -- Send file path
  vim.keymap.set("n", "<leader>ab", function()
    local path = buf_path()
    if not path then return end
    send_to_claude(path)
  end, { desc = "Send file path" })

  -- Send visual selection as file:range reference (Claude reads the file itself)
  vim.keymap.set("v", "<leader>as", function()
    local path = buf_path()
    if not path then return end
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
    vim.api.nvim_feedkeys(esc, "nx", false)
    send_to_claude(path .. ":" .. start_line .. "-" .. end_line)
  end, { desc = "Send selection to Claude" })
end
