local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function isGsoServiceOpen()
  return string.find(vim.fn.getcwd(), "gso%-service")
end

local function getOptions()
  local gso_service_options = {
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-local-postgres.yml",
    "dbmigrate /users/tmoore/dev/gso-service.git/configs/gso-service-local-postgres.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-local-postgres-logging.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-local-postgres-tk-gateway.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-local-postgres-live-tk.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-local-postgres-master.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-local-postgres-jms-cache.yml",
    "dbmigrate /users/tmoore/dev/gso-service.git/configs/gso-service-local-postgres-master.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-tkqe3.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-rjqe.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-tkqe.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-jlqe2.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-prpvqe.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-nhqe2.yml",
    "server /users/tmoore/dev/gso-service.git/configs/gso-service-ekpvqe.yml",
  }

  local retail_payment_options = {
    "-Dspring.profiles.active=local",
  }

  if isGsoServiceOpen() then
    return gso_service_options
  else
    return retail_payment_options
  end
end

local function gsoServicePicker(opts)
  pickers
    .new(opts, {
      prompt_title = "gso service run configurations",
      finder = finders.new_table({
        results = getOptions(),
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          print(selection[1])
          if isGsoServiceOpen() then
            require("dap").continue({
              before = function(config)
                config.args = selection[1]
                return config
              end,
            })
          else
            require("dap").continue({
              before = function(config)
                config.vmArgs = selection[1]
                return config
              end,
            })
          end
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
    {
      "<leader>dr",
      function()
        require("dap").restart()
      end,
      desc = "Restart DAP",
    },
  },
}
