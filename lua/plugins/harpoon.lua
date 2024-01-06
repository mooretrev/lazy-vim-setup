return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  keys = function()
    local harpoon = require("harpoon")
    harpoon:setup({ settings = { sync_on_ui_close = true } })
    return {
      {
        "<C-h>",
        function()
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon list",
      },
      {
        "<leader>a",
        function()
          harpoon:list():append()
        end,
        desc = "Add harpoon",
      },
      {
        "<leader>h",
        function()
          harpoon:list():select(1)
        end,
        desc = "Harpoon first",
      },
      {
        "<leader>j",
        function()
          harpoon:list():select(2)
        end,
        desc = "Harpoon second",
      },
      {
        "<leader>k",
        function()
          harpoon:list():select(3)
        end,
        desc = "Harpoon thrid",
      },
      {
        "<leader>l",
        function()
          harpoon:list():select(4)
        end,
        desc = "Harpoon fourth",
      },
      {
        "<leader>n",
        function()
          harpoon:list():next({ ui_nav_wrap = true })
        end,
        desc = "Harpoon next",
      },
      {
        "<leader>p",
        function()
          harpoon:list():prev({ ui_nav_wrap = true })
        end,
        desc = "Harpoon prev",
      },
    }
  end,
}
