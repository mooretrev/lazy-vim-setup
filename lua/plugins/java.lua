local Util = require("lazyvim.util")

-- This is the same as in lspconfig.server_configurations.jdtls, but avoids
-- needing to require that when this module loads.
local java_filetypes = { "java" }

-- Utility function to extend or override a config table, similar to the way
-- that Plugin.opts works.
---@param config table
---@param custom function | table | nil
local function extend_or_override(config, custom, ...)
  if type(custom) == "function" then
    config = custom(config, ...) or config
  elseif custom then
    config = vim.tbl_deep_extend("force", config, custom) --[[@as table]]
  end
  return config
end

return {
  "mfussenegger/nvim-jdtls",
  dependencies = { "folke/which-key.nvim" },
  ft = java_filetypes,
  opts = function()
    return {
      -- How to find the root dir for a given filename. The default comes from
      -- lspconfig which provides a function specifically for java projects.
      root_dir = require("lspconfig.server_configurations.jdtls").default_config.root_dir,

      -- How to find the project name for a given root dir.
      project_name = function(root_dir)
        return root_dir and vim.fs.basename(root_dir)
      end,

      -- Where are the config and workspace dirs for a project?
      jdtls_config_dir = function(project_name)
        return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
      end,
      jdtls_workspace_dir = function(project_name)
        return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
      end,

      -- How to run jdtls. This can be overridden to a full java command-line
      -- if the Python wrapper script doesn't suffice.
      cmd = { vim.fn.exepath("jdtls") },
      full_cmd = function(opts)
        -- local fname = vim.api.nvim_buf_get_name(0)
        -- local root_dir = opts.root_dir(fname)
        -- local project_name = opts.project_name(root_dir)
        -- local cmd = vim.deepcopy(opts.cmd)
        -- if project_name then
        --   vim.list_extend(cmd, {
        --     "-configuration",
        --     "/Users/tmoore/dev/gso-service/gso-servic",
        --     -- opts.jdtls_config_dir(project_name),
        --     "-data",
        --     "/Users/tmoore/dev/gso-service/gso-servic",
        --     -- opts.jdtls_workspace_dir(project_name),
        --   })
        -- end
        local jdtls_setup = require("jdtls.setup")

        local home = os.getenv("HOME")
        local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
        local root_dir = jdtls_setup.find_root(root_markers)

        local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
        local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name

        -- 💀
        local path_to_mason_packages = home .. "/.local/share/nvim/mason/packages"
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^

        local path_to_jdtls = path_to_mason_packages .. "/jdtls"
        local path_to_jdebug = path_to_mason_packages .. "/java-debug-adapter"
        local path_to_jtest = path_to_mason_packages .. "/java-test"

        local path_to_config = path_to_jdtls .. "/config_mac"
        local lombok_path = path_to_jdtls .. "/lombok.jar"

        -- 💀
        local path_to_jar = path_to_jdtls .. "/plugins/org.eclipse.equinox.launcher_1.6.600.v20231106-1826.jar"
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^

        return {
          --
          -- 				-- 💀
          "/Users/tmoore/.sdkman/candidates/java/17.0.9-zulu/bin/java", -- or '/path/to/java17_or_newer/bin/java'
          -- depends on if `java` is in your $PATH env variable and if it points to the right version.

          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xmx1g",
          "-javaagent:" .. lombok_path,
          "--add-modules=ALL-SYSTEM",
          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",
          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",

          -- 💀
          "-jar",
          path_to_jar,
          -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
          -- Must point to the                                                     Change this to
          -- eclipse.jdt.ls installation                                           the actual version

          -- 💀
          "-configuration",
          path_to_config,
          -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
          -- Must point to the                      Change to one of `linux`, `win` or `mac`
          -- eclipse.jdt.ls installation            Depending on your system.

          -- 💀
          -- See `data directory configuration` section in the README
          "-data",
          workspace_dir,
        }
      end,

      -- These depend on nvim-dap, but can additionally be disabled by setting false here.
      dap = { hotcodereplace = "auto", config_overrides = {} },
      test = true,
    }
  end,
  config = function()
    local opts = Util.opts("nvim-jdtls") or {}

    -- Find the extra bundles that should be passed on the jdtls command-line
    -- if nvim-dap is enabled with java debug/test.
    local mason_registry = require("mason-registry")
    local bundles = {} ---@type string[]
    if opts.dap and Util.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
      local java_dbg_pkg = mason_registry.get_package("java-debug-adapter")
      local java_dbg_path = java_dbg_pkg:get_install_path()
      local jar_patterns = {
        java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
      }
      -- java-test also depends on java-debug-adapter.
      if opts.test and mason_registry.is_installed("java-test") then
        local java_test_pkg = mason_registry.get_package("java-test")
        local java_test_path = java_test_pkg:get_install_path()
        vim.list_extend(jar_patterns, {
          java_test_path .. "/extension/server/*.jar",
        })
      end
      for _, jar_pattern in ipairs(jar_patterns) do
        for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
          table.insert(bundles, bundle)
        end
      end
    end

    local function attach_jdtls()
      local fname = vim.api.nvim_buf_get_name(0)

      -- Configuration can be augmented and overridden by opts.jdtls
      local config = extend_or_override({
        cmd = opts.full_cmd(opts),
        root_dir = opts.root_dir(fname),
        init_options = {
          bundles = bundles,
        },
        settings = {
          java = {
            path = "/Users/tmoore/.sdkman/candidates/java/11.0.21-zulu/zulu-11.jdk/Contents/Home",

            eclipse = {
              downloadSources = true,
            },
            maven = {
              downloadSources = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            references = {
              includeDecompiledSources = true,
            },
            inlayHints = {
              parameterNames = {
                enabled = "all", -- literals, all, none
              },
            },
            import = {
              gradle = {

                -- java = {
                --   home = "/Users/tmoore/.sdkman/candidates/java/11.0.21-zulu",
                -- },
              },
            },
            configuration = {
              -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
              -- And search for `interface RuntimeOption`
              -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
              runtimes = {
                {
                  name = "JavaSE-11",
                  path = "/Users/tmoore/.sdkman/candidates/java/11.0.21-zulu/zulu-11.jdk/Contents/Home",
                },
                {
                  name = "JavaSE-17",
                  path = "/Users/tmoore/.sdkman/candidates/java/17.0.9-zulu",
                },
              },
            },
          },
        },
        -- enable CMP capabilities
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      }, opts.jdtls)

      -- Existing server will be reused if the root_dir matches.
      require("jdtls").start_or_attach(config)
      -- not need to require("jdtls.setup").add_commands(), start automatically adds commands
    end

    -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
    -- depending on filetype, so this autocmd doesn't run for the first file.
    -- For that, we call directly below.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = java_filetypes,
      callback = attach_jdtls,
    })

    -- Setup keymap and dap after the lsp is fully attached.
    -- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
    -- https://neovim.io/doc/user/lsp.html#LspAttach
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "jdtls" then
          local wk = require("which-key")
          wk.register({
            ["<leader>cx"] = { name = "+extract" },
            ["<leader>cxv"] = { require("jdtls").extract_variable_all, "Extract Variable" },
            ["<leader>cxc"] = { require("jdtls").extract_constant, "Extract Constant" },
            ["gs"] = { require("jdtls").super_implementation, "Goto Super" },
            ["gS"] = { require("jdtls.tests").goto_subjects, "Goto Subjects" },
            ["<leader>co"] = { require("jdtls").organize_imports, "Organize Imports" },
          }, { mode = "n", buffer = args.buf })
          wk.register({
            ["<leader>c"] = { name = "+code" },
            ["<leader>cx"] = { name = "+extract" },
            ["<leader>cxm"] = {
              [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
              "Extract Method",
            },
            ["<leader>cxv"] = {
              [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
              "Extract Variable",
            },
            ["<leader>cxc"] = {
              [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
              "Extract Constant",
            },
          }, { mode = "v", buffer = args.buf })

          if opts.dap and Util.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
            -- custom init for Java debugger
            require("jdtls").setup_dap(opts.dap)
            require("jdtls.dap").setup_dap_main_class_configs()

            -- Java Test require Java debugger to work
            if opts.test and mason_registry.is_installed("java-test") then
              -- custom keymaps for Java test runner (not yet compatible with neotest)
              wk.register({
                ["<leader>t"] = { name = "+test" },
                ["<leader>tt"] = { require("jdtls.dap").test_class, "Run All Test" },
                ["<leader>tr"] = { require("jdtls.dap").test_nearest_method, "Run Nearest Test" },
                ["<leader>tT"] = { require("jdtls.dap").pick_test, "Run Test" },
              }, { mode = "n", buffer = args.buf })
            end
          end

          -- User can set additional keymaps in opts.on_attach
          if opts.on_attach then
            opts.on_attach(args)
          end
        end
      end,
    })

    -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
    attach_jdtls()
  end,
}
--
--
--
-- return {
--   "mfussenegger/nvim-jdtls",
--   opts = function()
--     return {
--       -- How to find the root dir for a given filename. The default comes from
--       -- lspconfig which provides a function specifically for java projects.
--       root_dir = require("lspconfig.server_configurations.jdtls").default_config.root_dir,
--
--       -- How to find the project name for a given root dir.
--       project_name = function(root_dir)
--         return root_dir and vim.fs.basename(root_dir)
--       end,
--
--       -- Where are the config and workspace dirs for a project?
--       jdtls_config_dir = function(project_name)
--         return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
--       end,
--       jdtls_workspace_dir = function(project_name)
--         return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
--       end,
--
--       -- How to run jdtls. This can be overridden to a full java command-line
--       -- if the Python wrapper script doesn't suffice.
--       cmd = { vim.fn.exepath("jdtls") },
--       full_cmd = function(opts)
--         local fname = vim.api.nvim_buf_get_name(0)
--         local root_dir = opts.root_dir(fname)
--         local project_name = opts.project_name(root_dir)
--         local cmd = vim.deepcopy(opts.cmd)
--         if project_name then
--           vim.list_extend(cmd, {
--             "-configuration",
--             opts.jdtls_config_dir(project_name),
--             "-data",
--             opts.jdtls_workspace_dir(project_name),
--           })
--         end
--         return cmd
--       end,
--
--       -- These depend on nvim-dap, but can additionally be disabled by setting false here.
--       dap = { hotcodereplace = "auto", config_overrides = {} },
--       test = true,
-- settings = {
--   java = {
--     configuration = {
--       -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
--       -- And search for `interface RuntimeOption`
--       -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
--       runtimes = {
--         {
--           name = "JavaSE-11",
--           path = "/Users/tmoore/.sdkman/candidates/java/11.0.21-zulu",
--         },
--         {
--           name = "JavaSE-17",
--           path = "/Users/tmoore/.sdkman/candidates/java/17.0.9-zulu",
--         },
--       },
--     },
--   },
-- },
--     }
--   end,
-- }

-- opts = function(_, _opts)
--   return {
--     full_cmd = _opts.full_cmd,
--     root_dir = _opts.root_dir,
-- settings = {
--   java = {
--     configuration = {
--       -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
--       -- And search for `interface RuntimeOption`
--       -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
--       runtimes = {
--         {
--           name = "JavaSE-11",
--           path = "/Users/tmoore/.sdkman/candidates/java/11.0.21-zulu",
--         },
--         {
--           name = "JavaSE-17",
--           path = "/Users/tmoore/.sdkman/candidates/java/17.0.9-zulu",
--         },
--       },
--     },
--   },
-- },
--   }
-- end,
-- setup = {
--   jdtls = function(_, opts)
--     vim.api.nvim_create_autocmd("FileType", {
--       pattern = "java",
--       callback = function()
--         -- local workspace_dir = "/home/jake/.workspace/" .. project_name -- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
--         vim.lsp.set_log_level("DEBUG")
--         local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
--         local workspace_dir = "/Users/tmoore/.workspace/" .. project_name
--
--         local config = {
--           cmd = {
--
--             "/Users/tmoore/.sdkman/candidates/java/17.0.9-zulu/bin/java", -- or '/path/to/java17_or_newer/bin/java'
--             "-Declipse.application=org.eclipse.jdt.ls.core.id1",
--             "-Dosgi.bundles.defaultStartLevel=4",
--             "-Declipse.product=org.eclipse.jdt.ls.core.product",
--             "-Dlog.protocol=true",
--             "-Dlog.level=ALL",
--             "-Xmx1g",
--             "--add-modules=ALL-SYSTEM",
--             "--add-opens",
--             "java.base/java.util=ALL-UNNAMED",
--
--             "--add-opens",
--             "java.base/java.lang=ALL-UNNAMED",
--
--             "-jar",
--             "/usr/local/Cellar/jdtls/1.30.1/libexec/plugins/org.eclipse.equinox.launcher_1.6.600.v20231106-1826.jar",
--
--             "-configuration",
--             "/usr/local/Cellar/jdtls/1.30.1/libexec/config_mac",
--
--             "-data",
--             workspace_dir,
--           },
--
--           root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
--           settings = {
--             java = {
--               eclipse = {
--                 downloadSources = true,
--               },
--               maven = {
--                 downloadSources = true,
--               },
--               referencesCodeLens = {
--                 enabled = true,
--               },
--               references = {
--                 includeDecompiledSources = true,
--               },
--               inlayHints = {
--                 parameterNames = {
--                   enabled = "all", -- literals, all, none
--                 },
--               },
--               configuration = {
--                 runtimes = {
--                   {
--                     name = "JavaSE-11",
--                     path = "/Users/tmoore/.sdkman/candidates/java/11.0.21-zulu",
--                   },
--                   {
--                     name = "JavaSE-17",
--                     path = "/Users/tmoore/.sdkman/candidates/java/17.0.9-zulu",
--                   },
--                 },
--               },
--             },
--           },
--         }
--         require("jdtls").start_or_attach(config)
--       end,
--     })
--     return true
--   end,
-- },
