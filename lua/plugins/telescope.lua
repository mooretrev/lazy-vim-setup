return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- disable the keymap to grep files
      { "<leader>fg", "<cmd>Telescope live_grep <cr>", desc = "Grep (Find All)" },
      { "<leader>fo", "<cmd> Telescope oldfiles <CR>", desc = "Find oldfiles" },
      { "<leader>ff", "<cmd> Telescope find_files <CR>", desc = "Find all files" },
      { "<leader>fb", "<cmd> Telescope git_branches <CR>", desc = "Find git branches" },
      { "<leader>fs", "<cmd> Telescope git_status <CR>", desc = "Find git files changes" },
      { "<leader>gs", false},
      { "<leader>/", false },
    },
  },
}
