local dap_console_open = false
return {
  "rcarriga/nvim-dap-ui",
  opts = {
    layouts = {
      {
        elements = {
          {
            id = "scopes",
            size = 0.25,
          },
          {
            id = "breakpoints",
            size = 0.25,
          },
          {
            id = "stacks",
            size = 0.25,
          },
          {
            id = "watches",
            size = 0.25,
          },
        },
        position = "left",
        size = 40,
      },
      {
        elements = {
          {
            id = "console",
            size = 0.8,
          },
          {
            id = "repl",
            size = 0.2,
          },
        },
        position = "bottom",
        size = 30,
      },
    },
  },
  keys = {
    {
      "<leader>dU",
      function()
        if dap_console_open then
          require("dapui").close({ layout = 2 })
          dap_console_open = false
        else
          require("dapui").open({ layout = 2 })
          dap_console_open = true
        end
      end,
      desc = "DAP UI Console",
    },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(nil, vim.fn.input("Breakpoint hit condition: "))
      end,
      desc = "Breakpoint Hit Condition",
    },
  },
  config = function(_, opts)
    local dap = require("dap")
    local dapui = require("dapui")
    dapui.setup(opts)
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open({})
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close({})
    end
  end,
}
