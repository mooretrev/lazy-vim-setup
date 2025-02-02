PreviousCommand = ""
local stopTestRunner = function()
  vim.cmd("VimuxInterruptRunner")
  vim.cmd("VimuxInterruptRunner")
  vim.cmd("VimuxInterruptRunner")
end

return {
  "preservim/vimux",
  lazy = false,
  keys = {
    {

      "<leader>tr",
      function()
        local working_dir = vim.fn.getcwd()
        local filename = vim.api.nvim_buf_get_name(0)
        local line_number = vim.api.nvim_win_get_cursor(0)[1]
        local cucumber_command = string.format("cucumber %s -l %s -f progress", filename, line_number)
        local command =
          string.format('VimuxRunCommand("clear && cd %s/cucumber-tests && %s")', working_dir, cucumber_command)
        stopTestRunner()
        vim.cmd(command)
        PreviousCommand = command
        print(cucumber_command)
      end,
      desc = "Run nearest test",
      ft = "cucumber",
    },
    {

      "<leader>tt",
      function()
        local working_dir = vim.fn.getcwd()
        local filename = vim.api.nvim_buf_get_name(0)
        local cucumber_command = string.format("cucumber %s -f progress", filename)
        local command =
          string.format('VimuxRunCommand("clear && cd %s/cucumber-tests && %s")', working_dir, cucumber_command)
        stopTestRunner()
        vim.cmd(command)
        PreviousCommand = command
        print(cucumber_command)
      end,
      desc = "Run all tests",
      ft = "cucumber",
    },
    {
      "<leader>tt",
      function()
        local command = 'VimuxRunCommand("clear; cd /Users/tmoore/dev/gso-ui; nvm use 12; npm run test")'
        stopTestRunner()
        vim.cmd(command)
      end,
      desc = "npm test",
      ft = { "javascript", "typescript", "javascript-react", "typescript-react" },
    },
    {
      "<leader>tr",
      function()
        local command = 'VimuxRunCommand("clear; cd /Users/tmoore/dev/gso-ui; nvm use 12; npm run component")'
        stopTestRunner()
        vim.cmd(command)
      end,
      desc = "Open cypress",
      ft = { "javascript", "typescript", "javascript-react", "typescript-react" },
    },
    {

      "<leader>tp",
      function()
        stopTestRunner()
        vim.cmd(PreviousCommand)
        print(PreviousCommand)
      end,
      desc = "Run previous test",
      ft = { "javascript", "typescript", "javascript-react", "typescript-react", "java", "cucumber" },
    },
    {

      "<leader>r",
      function()
        stopTestRunner()
        local session = require("dap").session()
        if session == nil then
          require("dap").continue()
        else
          require("dap").restart()
        end
        vim.cmd(PreviousCommand)
        print(PreviousCommand)
      end,
      desc = "Run previous test",
    },
    {

      "<leader>tc",
      function()
        stopTestRunner()
      end,
      desc = "Cancel test runner command",
    },
    {

      "<leader>tC",
      function()
        vim.cmd("VimuxCloseRunner")
      end,
      desc = "Cancel test runner command",
    },
    {
      "<leader>to",
      function()
        local working_dir = vim.fn.getcwd()
        local command = string.format('VimuxRunCommand("clear && cd %s")', working_dir)
        vim.cmd(command)
        print(command)
      end,
      desc = "Open Terminal",
    },
  },
}
