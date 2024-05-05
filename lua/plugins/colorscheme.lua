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
      flavour = "frappe", -- latte, frappe, macchiato, mocha
      transparent_background = true,

      -- dim_inactive = {
      --   enabled = true, -- dims the background color of inactive window
      --   shade = "dark",
      --   -- percentage = 0.9, -- percentage of the shade to apply to the inactive window
      -- },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
