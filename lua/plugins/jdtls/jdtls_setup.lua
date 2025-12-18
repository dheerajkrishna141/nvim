local M = {}

-- Helper function to find lombok.jar
local function find_lombok_jar()
	local home = vim.fn.expand("~")

	-- Try known locations for lombok.jar
	local paths = {
		-- Maven repository
		home .. "/.m2/repository/org/projectlombok/lombok/1.18.38/lombok-1.18.38.jar",
		home .. "/.m2/repository/org/projectlombok/lombok/1.18.36/lombok-1.18.36.jar",
		home .. "/.m2/repository/org/projectlombok/lombok/1.18.34/lombok-1.18.34.jar",
		home .. "/.m2/repository/org/projectlombok/lombok/1.18.32/lombok-1.18.32.jar",
		home .. "/.m2/repository/org/projectlombok/lombok/1.18.30/lombok-1.18.30.jar",
	}

	-- Check each path
	for _, path in ipairs(paths) do
		if vim.fn.filereadable(path) == 1 then
			return path
		end
	end

	-- Fallback: try to glob for any lombok jar
	local glob_result = vim.fn.glob(home .. "/.m2/repository/org/projectlombok/lombok/*/lombok-*.jar", false, true)
	for _, jar in ipairs(glob_result) do
		if not jar:match("sources") and not jar:match("javadoc") and vim.fn.filereadable(jar) == 1 then
			return jar
		end
	end

	return nil
end

function M:setup()
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_name

	-- Build the base cmd array
	local cmd = {
		-- 💀
		"java", -- or '/path/to/java17_or_newer/bin/java'
		-- depends on if `java` is in your $PATH env variable and if it points to the right version.

		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx1g",
	}

	-- Add Lombok agent if found
	local lombok_jar = find_lombok_jar()
	if lombok_jar then
		vim.notify("JDTLS: Found Lombok at " .. lombok_jar, vim.log.levels.INFO)
		table.insert(cmd, "-javaagent:" .. lombok_jar)
	else
		vim.notify("JDTLS: Lombok jar not found, annotation processing disabled", vim.log.levels.WARN)
	end

	-- Continue with remaining arguments
	vim.list_extend(cmd, {
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",

		-- 💀
		"-jar",
		"/home/kratosfury/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.7.100.v20251111-0406.jar",
		-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
		-- Must point to the                                                     Change this to
		-- eclipse.jdt.ls installation                                           the actual version

		-- 💀
		"-configuration",
		"/home/kratosfury/.local/share/nvim/mason/packages/jdtls/config_linux",
		-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
		-- Must point to the                      Change to one of `linux`, `win` or `mac`
		-- eclipse.jdt.ls installation            Depending on your system.

		-- 💀
		-- See `data directory configuration` section in the README
		"-data",
		workspace_dir,
	})

	local config = {
		-- The command that starts the language server
		-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
		cmd = cmd,

		-- 💀
		-- This is the default if not provided, you can remove it. Or adjust as needed.
		-- One dedicated LSP server & client will be started per unique root_dir
		root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),

		-- Here you can configure eclipse.jdt.ls specific settings
		-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
		-- for a list of options
		settings = {
			java = {
				-- Enable Lombok annotation processing
				jdt = {
					ls = {
						lombokSupport = {
							enabled = true,
						},
					},
				},
			},
		},

		-- Language server `initializationOptions`
		-- You need to extend the `bundles` with paths to jar files
		-- if you want to use additional eclipse.jdt.ls plugins.
		--
		-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
		--
		-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
		init_options = {
			bundles = {},
		},
	}
	-- This starts a new client & server,
	-- or attaches to an existing client & server depending on the `root_dir`.
	require("jdtls").start_or_attach(config)
end

return M
