-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Zellij helpers for Claude Code pane (tiled, to the right of Neovim)
if vim.env.ZELLIJ then
  local function zellij(args)
    vim.fn.system(vim.list_extend({ "zellij", "action" }, args))
  end

  --- Check if a pane with the given command exists in the current layout.
  local function has_pane(command)
    local layout = vim.fn.system("zellij action dump-layout")
    local pattern = 'command="' .. vim.pesc(command) .. '"'
    return layout:match(pattern) ~= nil
  end

  --- Check if the currently focused pane matches the given command.
  local function focused_pane_is(command)
    local layout = vim.fn.system("zellij action dump-layout")
    local pattern = 'command="' .. vim.pesc(command) .. '"'
    for line in layout:gmatch("[^\n]+") do
      if line:match(pattern) and line:match("focus=true") then
        return true
      end
    end
    return false
  end

  --- Cycle through panes until the focused pane matches the target command.
  --- Checks dump-layout after each focus-next-pane to verify we landed
  --- on the right pane, so it works regardless of layout arrangement.
  local function focus_pane(command)
    if focused_pane_is(command) then return true end
    if not has_pane(command) then
      vim.notify("No " .. command .. " pane found", vim.log.levels.WARN)
      return false
    end
    for _ = 1, 10 do
      zellij({ "focus-next-pane" })
      if focused_pane_is(command) then return true end
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
  local function send_to_claude(text)
    if not focus_claude() then return end
    write_chars(text)
    focus_neovim()
  end

  local function buf_path()
    local path = vim.fn.expand("%:.")
    if path == "" then
      vim.notify("Buffer has no file", vim.log.levels.WARN)
      return nil
    end
    return path
  end

  -- Open Claude Code in a tiled pane to the right (guards against duplicates)
  vim.keymap.set("n", "<leader>ac", function()
    if has_pane("claude") then
      vim.notify("Claude pane already open, use <leader>af to focus", vim.log.levels.INFO)
      return
    end
    vim.fn.system({
      "zellij", "run",
      "--direction", "right",
      "--name", "Claude Code",
      "--close-on-exit",
      "--", "zsh", "-ic", "claude",
    })
  end, { desc = "Open Claude Code" })

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
