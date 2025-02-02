-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set({ "n", "v", "x" }, "<leader>p", [["_dP]], { desc = "Repeat pasting" })

local Util = require("lazyvim.util")

-- Function to check clipboard with retries
local function getRelativeFilepath(retries, delay)
  local relative_filepath
  for i = 1, retries do
    relative_filepath = vim.fn.getreg("+")
    if relative_filepath ~= "" then
      return relative_filepath -- Return filepath if clipboard is not empty
    end
    vim.loop.sleep(delay) -- Wait before retrying
  end
  return nil -- Return nil if clipboard is still empty after retries
end

-- Function to handle editing from Lazygit
function LazygitEdit(original_buffer)
  local current_bufnr = vim.fn.bufnr("%")
  local channel_id = vim.fn.getbufvar(current_bufnr, "terminal_job_id")

  if not channel_id then
    vim.notify("No terminal job ID found.", vim.log.levels.ERROR)
    return
  end

  vim.fn.chansend(channel_id, "\15") -- \15 is <c-o>
  vim.cmd("close") -- Close Lazygit

  local relative_filepath = getRelativeFilepath(5, 50)
  if not relative_filepath then
    vim.notify("Clipboard is empty or invalid.", vim.log.levels.ERROR)
    return
  end

  local winid = vim.fn.bufwinid(original_buffer)

  if winid == -1 then
    vim.notify("Could not find the original window.", vim.log.levels.ERROR)
    return
  end

  vim.fn.win_gotoid(winid)
  vim.cmd("e " .. relative_filepath)
end

-- Function to start Lazygit in a floating terminal
function StartLazygit()
  local current_buffer = vim.api.nvim_get_current_buf()
  local float_term = Util.terminal.open({ "lazygit" }, { cwd = Util.root(), esc_esc = false, ctrl_hjkl = false })

  vim.api.nvim_buf_set_keymap(
    float_term.buf,
    "t",
    "<c-e>",
    string.format([[<Cmd>lua LazygitEdit(%d)<CR>]], current_buffer),
    { noremap = true, silent = true }
  )
end

vim.api.nvim_set_keymap("n", "<leader>gg", [[<Cmd>lua StartLazygit()<CR>]], { noremap = true, silent = true })

vim.keymap.set("n", "<c-/>", "", { remap = true })

vim.keymap.set("n", "<C-a>", "ggVG")
vim.keymap.set("n", "<leader>u2", ":set ts=2 sw=2<CR>")
vim.keymap.set("n", "<leader>u4", ":set ts=4 sw=4<CR>")
vim.keymap.set("n", "<leader>tr", ":%s/\\n/\r/g<CR>")
vim.keymap.set("n", "<leader>ts", "o@temp<CR>Scenario: temp<ESC>")
vim.keymap.set("n", "<leader>td", "?@temp<CR>dddd")
vim.keymap.set("n", "<leader>jf", function()
  vim.api.nvim_exec2("%s/\\n/", {})
  LazyVim.format({ force = true })
end, { desc = "Fix JSON" })
vim.keymap.set("n", "<leader>qf", ":cfirst<CR>", { desc = "[Q]uickfix [F]irst" })
vim.keymap.set("n", "<leader>ql", ":clast<CR>", { desc = "[Q]uickfix [L]ast" })
vim.keymap.set("n", "<leader>qo", ":copen<CR>", { desc = "[Q]uickfix [O]pen" })
vim.keymap.set("n", "<leader>qc", ":cclose<CR>", { desc = "[Q]uickfix [C]lose" })
vim.keymap.set("n", "<leader>qn", function()
  vim.ui.input({ prompt = "Enter value cnext: " }, function(input)
    local jump = tonumber(input)
    local command = "cnext " .. jump
    vim.cmd(command)
  end)
end, { desc = "[Q]uickfix [N]ext" })
