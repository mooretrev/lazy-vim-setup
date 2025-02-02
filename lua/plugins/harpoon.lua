return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  keys = {
    {
      "<C-e>",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Harpoon list",
    },
    {
      "<leader>h",
      function()
        require("harpoon"):list():add()
      end,
      desc = "Add harpoon",
    },
    {
      "<C-n>",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "Harpoon first",
    },
    {
      "<C-m>",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "Harpoon second",
    },
    {
      "<C-y>",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "Harpoon thrid",
    },
    {
      "<C-w>",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "Harpoon fourth",
    },
    {
      "<leader>1",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "Harpoon first",
    },
    {
      "<leader>2",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "Harpoon second",
    },
    {
      "<leader>3",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "Harpoon thrid",
    },
    {
      "<leader>4",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "Harpoon fourth",
    },
    {
      "<leader>5",
      function()
        require("harpoon"):list():select(5)
      end,
      desc = "Harpoon fourth",
    },

    {
      "<leader>n",
      function()
        require("harpoon"):list():next({ ui_nav_wrap = true })
      end,
      desc = "Harpoon next",
    },
    {
      "<leader>p",
      function()
        require("harpoon"):list():prev({ ui_nav_wrap = true })
      end,
      desc = "Harpoon prev",
    },
  },
}
