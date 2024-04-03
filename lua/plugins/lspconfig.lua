return {
  "neovim/nvim-lspconfig",
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
