-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt["tabstop"] = 2
vim.opt["shiftwidth"] = 2
vim.opt["scrolloff"] = 10
vim.opt.spelllang = "en_us"
vim.opt.spell = true
vim.cmd('let g:VimuxOrientation = "h"')
vim.cmd('let g:VimuxWidth = "40"')
vim.cmd("let g:VimuxCloseOnExit = 1")
vim.cmd('let g:fubitive_domain_pattern = "stash.pros.com"')
-- vim.cmd('let g:fubitive_domain_context_path = ""')
vim.lsp.set_log_level("INFO")
vim.opt.sessionoptions = "blank,buffers,curdir,folds,globals,help,options,tabpages,winsize,terminal"
vim.g.snacks_animate = false
