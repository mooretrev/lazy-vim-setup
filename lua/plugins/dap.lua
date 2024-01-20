local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function gsoServicePicker(opts)
  pickers
    .new(opts, {
      prompt_title = "gso service run configurations",
      finder = finders.new_table({
        results = {
          "server gso-service/gso-service-oracle-xe.yml",
          "dbmigrate gso-service/gso-service-oracle-xe.yml",
          "server gso-service/gso-service-rjqe.yml",
        },
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          print(selection[1])
          require("dap").continue({
            before = function(config)
              config.args = selection[1]
              return config
            end,
          })
        end)
        return true
      end,
    })
    :find()
end

return {
  "mfussenegger/nvim-dap",
  keys = {
    {
      "<leader>da",
      function(opts)
        opts = opts or {}
        gsoServicePicker(opts)
      end,
      desc = "Run with Args",
    },
  },
}
