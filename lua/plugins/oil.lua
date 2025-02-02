local detail = false
return {
  "stevearc/oil.nvim",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "-", "<cmd>Oil <CR>", desc = "Open parent directory" },
  },
  config = function()
    require("oil").setup({
      columns = {
        "icon",
        "mtime",
      },
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = false,
        ["<C-h>"] = false,
        ["<C-t>"] = false,
        ["<C-p>"] = false,
        ["<C-c>"] = false,
        ["<C-l>"] = false,
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = false,
        ["~"] = false,
        ["gx"] = false,
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
        ["gs"] = {
          desc = "Toggle file detail view",
          callback = function()
            detail = not detail
            if detail then
              require("oil").set_sort({ { "mtime", "desc" } })
            else
              require("oil").set_sort({
                { "type", "asc" },
                { "name", "asc" },
              })
            end
          end,
        },
        ["gr"] = "actions.refresh",
      },
    })
  end,
}
