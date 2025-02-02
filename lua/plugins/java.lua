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
local is_class_test = false
local previous_context = nil
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
      "<leader>ju",
      function()
        require("jdtls").update_projects_config({ select_mode = "all" })
      end,
      desc = "JDTLS update project",
    },
    {
      "<leader>jr",
      function()
        require("jdtls").set_runtime()
      end,
      desc = "JDTLS set runtime",
    },
    {
      "<leader>jd",
      "<cmd>JdtUpdateDebugConfig<cr>",
      desc = "JdtUpdateDebugConfig",
    },
    -- {
    --   "<leader>tr",
    --   function()
    --     vim.print("Hi")
    --     is_class_test = false
    --     previous_context = {
    --       bufnr = vim.api.nvim_get_current_buf(),
    --       lnom = vim.api.nvim_win_get_cursor(0)[1],
    --     }
    --     vim.print(previous_context)
    --     require("jdtls").test_nearest_method()
    --   end,
    -- },
  },
  opts = function(_, opts)
    return vim.tbl_deep_extend("keep", {
      full_cmd = function()
        local jdtls_setup = require("jdtls.setup")

        local home = os.getenv("HOME")
        local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
        local root_dir = jdtls_setup.find_root(root_markers)

        local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
        local branch_name = vim.fn.fnamemodify(require("git-worktree").get_current_worktree_path() or "master", ":t")
          or "main"
        local dir = project_name .. "/" .. branch_name
        local workspace_dir = home .. "/.cache/jdtls/workspace/" .. dir

        -- 💀
        local path_to_mason_packages = home .. "/.local/share/nvim/mason/packages"
        -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^

        local path_to_jdtls = path_to_mason_packages .. "/jdtls"

        local path_to_config = path_to_jdtls .. "/config_mac_arm"
        local lombok_path = path_to_jdtls .. "/lombok.jar"

        -- 💀
        local path_to_jar = path_to_jdtls .. "/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar"
        return {

          "/Users/tmoore/.sdkman/candidates/java/17.0.11.fx-zulu/zulu-17.jdk/Contents/Home/bin/java", -- or '/path/to/java17_or_newer/bin/java'
          -- depends on if `java` is in your $PATH env variable and if it points to the right version.

          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xmx8g",
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
      dap = {
        config_overrides = {
          -- args = "-Dspring.profiles.active=local -Dspring.config.location=/Users/tmoore/dev/retail-payment/src/main/resources/application-local.properties",
          -- vmArgs = "-Dspring.profiles.active=local"
        },
      },
      jdtls = {
        settings = {
          java = {
            home = "/Users/tmoore/.sdkman/candidates/java/17.0.11.fx-zulu/zulu-17.jdk/Contents/Home",
            import = {
              gradle = {
                -- java = {
                --   home = "/Users/tmoore/.sdkman/candidates/java/11.0.21-zulu/zulu-11.jdk/Contents/Home",
                -- },
                -- offline = {
                --   enabled = true,
                -- },
              },
            },
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
            format = {
              enabled = true,
              settings = {
                -- profile = "default",
                url = "/Users/tmoore/dev/java-style.xml",
              },
              tabSize = true,
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
    }, opts)
  end,
  -- config = function(_, opts)
  --   -- Find the extra bundles that should be passed on the jdtls command-line
  --   -- if nvim-dap is enabled with java debug/test.
  --   local bundles = {} ---@type string[]
  --   if LazyVim.has("mason.nvim") then
  --     local mason_registry = require("mason-registry")
  --     if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
  --       local java_dbg_pkg = mason_registry.get_package("java-debug-adapter")
  --       local java_dbg_path = java_dbg_pkg:get_install_path()
  --       local jar_patterns = {
  --         java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
  --       }
  --       -- java-test also depends on java-debug-adapter.
  --       if opts.test and mason_registry.is_installed("java-test") then
  --         local java_test_pkg = mason_registry.get_package("java-test")
  --         local java_test_path = java_test_pkg:get_install_path()
  --         vim.list_extend(jar_patterns, {
  --           java_test_path .. "/extension/server/*.jar",
  --         })
  --       end
  --       for _, jar_pattern in ipairs(jar_patterns) do
  --         for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
  --           table.insert(bundles, bundle)
  --         end
  --       end
  --     end
  --   end
  --   local function attach_jdtls()
  --     local fname = vim.api.nvim_buf_get_name(0)
  --
  --     -- Configuration can be augmented and overridden by opts.jdtls
  --     local config = extend_or_override({
  --       cmd = opts.full_cmd(opts),
  --       root_dir = opts.root_dir(fname),
  --       init_options = {
  --         bundles = bundles,
  --       },
  --       settings = opts.settings,
  --       -- enable CMP capabilities
  --       capabilities = LazyVim.has("cmp-nvim-lsp") and require("cmp_nvim_lsp").default_capabilities() or nil,
  --     }, opts.jdtls)
  --
  --     -- Existing server will be reused if the root_dir matches.
  --     require("jdtls").start_or_attach(config)
  --     -- not need to require("jdtls.setup").add_commands(), start automatically adds commands
  --   end
  --
  --   -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
  --   -- depending on filetype, so this autocmd doesn't run for the first file.
  --   -- For that, we call directly below.
  --   vim.api.nvim_create_autocmd("FileType", {
  --     pattern = java_filetypes,
  --     callback = attach_jdtls,
  --   })
  --
  --   -- Setup keymap and dap after the lsp is fully attached.
  --   -- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
  --   -- https://neovim.io/doc/user/lsp.html#LspAttach
  --   vim.api.nvim_create_autocmd("LspAttach", {
  --     callback = function(args)
  --       local client = vim.lsp.get_client_by_id(args.data.client_id)
  --       if client and client.name == "jdtls" then
  --         local wk = require("which-key")
  --         wk.add({
  --           {
  --             mode = "n",
  --             buffer = args.buf,
  --             { "<leader>cx", group = "extract" },
  --             { "<leader>cxv", require("jdtls").extract_variable_all, desc = "Extract Variable" },
  --             { "<leader>cxc", require("jdtls").extract_constant, desc = "Extract Constant" },
  --             { "<leader>cgs", require("jdtls").super_implementation, desc = "Goto Super" },
  --             { "<leader>cgS", require("jdtls.tests").goto_subjects, desc = "Goto Subjects" },
  --             { "<leader>co", require("jdtls").organize_imports, desc = "Organize Imports" },
  --           },
  --         })
  --         wk.add({
  --           {
  --             mode = "v",
  --             buffer = args.buf,
  --             { "<leader>cx", group = "extract" },
  --             {
  --               "<leader>cxm",
  --               [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
  --               desc = "Extract Method",
  --             },
  --             {
  --               "<leader>cxv",
  --               [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
  --               desc = "Extract Variable",
  --             },
  --             {
  --               "<leader>cxc",
  --               [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
  --               desc = "Extract Constant",
  --             },
  --           },
  --         })
  --
  --         if LazyVim.has("mason.nvim") then
  --           local mason_registry = require("mason-registry")
  --           if opts.dap and LazyVim.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
  --             -- custom init for Java debugger
  --             require("jdtls").setup_dap(opts.dap)
  --             if opts.dap_main then
  --               require("jdtls.dap").setup_dap_main_class_configs(opts.dap_main)
  --             end
  --
  --             -- Java Test require Java debugger to work
  --             if opts.test and mason_registry.is_installed("java-test") then
  --               -- custom keymaps for Java test runner (not yet compatible with neotest)
  --               wk.add({
  --                 {
  --                   mode = "n",
  --                   buffer = args.buf,
  --                   { "<leader>t", group = "test" },
  --                   {
  --                     "<leader>tt",
  --                     function()
  --                       is_class_test = true
  --                       previous_context = {
  --                         bufnr = vim.api.nvim_get_current_buf(),
  --                         lnum = vim.api.nvim_win_get_cursor(0)[1],
  --                       }
  --                       require("jdtls.dap").test_class(previous_context)
  --                     end,
  --                     desc = "Run All Test",
  --                   },
  --                   {
  --                     "<leader>tr",
  --                     function()
  --                       is_class_test = false
  --                       previous_context = {
  --                         bufnr = vim.api.nvim_get_current_buf(),
  --                         lnum = vim.api.nvim_win_get_cursor(0)[1],
  --                       }
  --                       require("jdtls.dap").test_nearest_method(previous_context)
  --                     end,
  --                     desc = "Run Nearest Test",
  --                   },
  --                   {
  --                     "<leader>tp",
  --                     function()
  --                       if previous_context == nil then
  --                         vim.print("No previous context")
  --                         return
  --                       end
  --
  --                       if is_class_test then
  --                         require("jdtls").test_class(previous_context)
  --                       else
  --                         require("jdtls").test_nearest_method(previous_context)
  --                       end
  --                     end,
  --                   },
  --                 },
  --               })
  --             end
  --           end
  --         end
  --
  --         -- User can set additional keymaps in opts.on_attach
  --         if opts.on_attach then
  --           opts.on_attach(args)
  --         end
  --       end
  --     end,
  --   })
  --
  --   -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
  --   attach_jdtls()
  -- end,
}
