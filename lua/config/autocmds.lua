-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- vim.api.nvim_create_autocmd("FileType", {
--   group = augroup("wrap_spell"),
--   pattern = "*",
--   callback = function()
--     -- vim.opt_local.wrap = true
--     vim.opt_local.spell = true
--   end,
-- })

-- Disable autoformat for lua files
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "java", "xml", "ruby" },
  callback = function()
    vim.b.autoformat = false
  end,
})
