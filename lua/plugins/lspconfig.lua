return {
  "neovim/nvim-lspconfig",
  init = function()
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    keys[#keys + 1] = { "gr", "<cmd>Telescope lsp_references show_line=false<cr>", desc = "References" }
    keys[#keys + 1] = { "gI", "<cmd>Telescope lsp_implementations show_line=false<cr>", desc = "References" }
  end,
  opts = {
    servers = {
      solargraph = {},
      cucumber_language_server = {
        settings = {
          features = { "cucumber-tests/**/*.feature" },
          glue = { "cucumber-tests/**/*.rb", "/opt/homebrew/lib/ruby/gems/2.7.0/gems/json_spec-1.1.4/**/*.rb" },
          parameterTypes = {},
          snippetTemplates = {},
        },
        handlers = {
          ["workspace/configuration"] = function()
            return {
              {
                features = { "cucumber-tests/**/*.feature" },
                glue = { "cucumber-tests/**/*.rb", "/opt/homebrew/lib/ruby/gems/2.7.0/gems/json_spec-1.1.4/**/*.rb" },
                parameterTypes = {},
                snippetTemplates = {},
              },
            }
          end,
        },
      },
    },
  },
}
