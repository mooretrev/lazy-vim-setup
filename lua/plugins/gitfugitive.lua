return {
  "tpope/vim-fugitive",
  lazy = false,
  config = function()
    vim.keymap.set("n", "<leader>gs", "<cmd>Git<cr>", {})
  end,
  dependencies = { "tommcdo/vim-fubitive", lazy = false },
}
