-- better yank/paste
return {
  "gbprod/yanky.nvim",
  recommended = true,
  desc = "Better Yank/Paste",
  event = "LazyFile",
  opts = {
    highlight = { timer = 150 },
  },
  keys = {
    { "<leader>p", false, mode = { "n", "x" } },
    {
      "<leader>P",
      function()
        require("telescope").extensions.yank_history.yank_history({})
      end,
      mode = { "n", "x", "v" },
      desc = "Open Yank History",
    },
  },
}
