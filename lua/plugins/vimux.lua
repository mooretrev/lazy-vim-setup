return {
  "preservim/vimux",
  keys = {
    {

      "<leader>tr",
      function()
        local filename = vim.api.nvim_buf_get_name(0)
        local line_number = vim.api.nvim_win_get_cursor(0)[1]
        local cucumber_command = string.format("cucumber %s -l %s", filename, line_number)
        local command = string.format(
          'VimuxRunCommand("clear && cd /Users/tmoore/dev/gso-service/cucumber-tests && %s")',
          cucumber_command
        )
        vim.cmd(command)
        print(cucumber_command)
      end,
      desc = "Run nearest cucumber test",
      ft = "cucumber",
    },
    {

      "<leader>tt",
      function()
        local filename = vim.api.nvim_buf_get_name(0)
        local cucumber_command = string.format("cucumber %s", filename)
        local command = string.format(
          'VimuxRunCommand("clear && cd /Users/tmoore/dev/gso-service/cucumber-tests && %s")',
          cucumber_command
        )
        vim.cmd(command)
        print(cucumber_command)
      end,
      desc = "Run all cucumber tests",
      ft = "cucumber",
    },
  },
}
