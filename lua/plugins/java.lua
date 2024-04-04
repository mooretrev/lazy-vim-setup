return {
  "mfussenegger/nvim-jdtls",
  dependencies = { "folke/which-key.nvim" },
  keys = {
    { "<leader>jr", "<cmd>JdtRestart<cr>", desc = "Restart JDTLS" },
    {
      "<leader>jc",
      function()
        require("jdtls").compile("incremental")
      end,
      desc = "JDTLS compile",
    },
    {
      "<leader>jC",
      function()
        require("jdtls").compile("full")
      end,
      desc = "JDTLS full compile",
    },
    {
      "<leader>jw",
      "<cmd>JdtWipeDataAndRestart<cr>",
      desc = "JDTLS wipe and restart",
    },
    {
      "<leader>jr",
      function()
        require("jdtls").set_runtime()
      end,
      desc = "JDTLS set runtime",
    },
  },
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

      full_cmd = function()
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

        local path_to_config = path_to_jdtls .. "/config_mac_arm"
        local lombok_path = path_to_jdtls .. "/lombok.jar"

        -- 💀
        local path_to_jar = path_to_jdtls .. "/plugins/org.eclipse.equinox.launcher_1.6.600.v20231106-1826.jar"
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^

        return {
          --
          -- 				-- 💀
          "/Users/tmoore/.sdkman/candidates/java/17.0.9.fx-zulu/zulu-17.jdk/Contents/Home/bin/java", -- or '/path/to/java17_or_newer/bin/java'
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

      jdtls = {
        settings = {
          java = {
            home = "/Users/tmoore/.sdkman/candidates/java/17.0.9.fx-zulu/zulu-17.jdk/Contents/Home",

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
                  path = "/Users/tmoore/.sdkman/candidates/java/17.0.9.fx-zulu/zulu-17.jdk/Contents/Home",
                },
                {
                  name = "JavaSE-21",
                  path = "/Users/tmoore/.sdkman/candidates/java/21.0.2-zulu/zulu-21.jdk/Contents/Home",
                },
                {
                  name = "JavaSE-1.8",
                  path = "/Users/tmoore/.sdkman/candidates/java/8.0.392-zulu/zulu-8.jdk/Contents/Home",
                },
              },
            },
          },
        },
      },

      -- These depend on nvim-dap, but can additionally be disabled by setting false here.
      dap = {
        hotcodereplace = "auto",
        config_overrides = {
          -- useful cammand here
          -- lua require("jdtls.dap").setup_dap_main_class_configs( { config_overrides = { args = function() return vim.fn.input("Args: ") end } })
          args = "server gso-service/gso-service-oracle-xe.yml",
        },
      },
      test = true,
    }
  end,
}
