vim.g.copilot_proxy_strict_ssl = false

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      mappings = {
        complete = {
          insert = "<C-y>",
        },
        reset = {
          normal = "<C-e>",
          insert = "<C-e>",
        },
      },
    },
  },
  {

    "zbirenbaum/copilot.lua",
    opts = {},
  },
}
