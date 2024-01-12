return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  keys = function()
    local harpoon = require("harpoon")
    harpoon:setup({ settings = { sync_on_ui_close = true } })
    return {
      {
        "<C-e>",
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
        "<C-h>",
        function()
          harpoon:list():select(1)
        end,
        desc = "Harpoon first",
      },
      {
        "<C-j>",
        function()
          harpoon:list():select(2)
        end,
        desc = "Harpoon second",
      },
      {
        "<leader>k",
        "<C-u>",
        function()
          harpoon:list():select(3)
        end,
        desc = "Harpoon thrid",
      },
      {
        "<C-y>",
        function()
          harpoon:list():select(4)
        end,
        desc = "Harpoon fourth",
      },
      {
        "<C-n>",
        function()
          harpoon:list():next({ ui_nav_wrap = true })
        end,
        desc = "Harpoon next",
      },
      {
        "<C-m>",
        function()
          harpoon:list():prev({ ui_nav_wrap = true })
        end,
        desc = "Harpoon prev",
      },
    }
  end,
}
