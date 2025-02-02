return {
  "folke/trouble.nvim",
  opts = {
    use_diagnostic_signs = true,
    severity = vim.diagnostic.severity.ERROR,
  },
  keys = {
    {
      "<leader>xe",
      "<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.ERROR<cr>",
      desc = "Diagnostics Errors (Trouble)",
    },
  },
}
