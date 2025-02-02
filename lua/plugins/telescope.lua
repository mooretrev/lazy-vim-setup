return {
  "nvim-telescope/telescope.nvim",
  keys = {
    -- disable the keymap to grep files
    { "<leader>fg", "<cmd>Telescope live_grep <cr>", desc = "Grep (Find All)" },
    { "<leader>fo", "<cmd> Telescope oldfiles <CR>", desc = "Find oldfiles" },
    { "<leader>ff", "<cmd> Telescope find_files <CR>", desc = "Find all files" },
    { "<leader>fb", "<cmd> Telescope git_branches <CR>", desc = "Find git branches" },
    { "<leader>fs", "<cmd> Telescope git_status <CR>", desc = "Find git files changes" },
    { "<leader>fy", "<cmd> Telescope yank_history <CR>", desc = "Show yank history" },
    {
      "<leader>fm",
      "<cmd> lua require('telescope.builtin').lsp_document_symbols({ symbols='method' }) <CR>",
      desc = "Search methods",
    },
    { "<leader>gs", false },
    { "<leader>/", false },
    {
      "<leader>fw",
      function()
        require("telescope").extensions.git_worktree.git_worktrees()
      end,
      desc = "Git worktrees",
    },
    {
      "<leader>fW",
      function()
        require("telescope").extensions.git_worktree.create_git_worktree()
      end,
      desc = "Create git worktree",
    },
  },
  opts = function(_, opts)
    require("git-worktree").setup()
    require("telescope").load_extension("git_worktree")
    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.50,
          results_width = 0.50,
        },
        vertical = {
          mirror = false,
        },
        width = 0.99,
        height = 0.99,
        preview_cutoff = 150,
      },
    })
    return opts
  end,
}
