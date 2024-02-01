return {
  {
    "cormacrelf/dark-notify",
    lazy = false,
    config = function()
      local dn = require("dark_notify")
      dn.run()
    end,
  },

  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      transparent_background = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
