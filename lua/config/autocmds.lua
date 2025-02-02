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

-- Disable autoformat for file types
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "java", "ruby", "xml" },
  callback = function()
    vim.b["autoformat"] = false
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "java" },
  callback = function()
    vim.bo.indentkeys = "0},0),0],:,0#,!^F,o,O,e,0=end,0=until"
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "java", "xml", "json" },
  callback = function()
    vim.opt["tabstop"] = 4
    vim.opt["shiftwidth"] = 4
    vim.cmd("set shiftwidth=4")
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "ruby", "*.feature" },
  callback = function()
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.expandtab = true
    vim.bo.softtabstop = 2
  end,
})
