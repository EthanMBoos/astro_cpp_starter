--[[
--============================================================================
--                        DAP Debugging Flow: Host -> Docker
--============================================================================
--
--   HOST MACHINE (Your Laptop)
--   +-----------------------------------------------------------------------+
--   |                                                                       |
--   |  1. You set a breakpoint in AstroNvim.                                |
--   |     |                                                                 |
--   |     V                                                                 |
--   |  [ nvim-dap plugin ]                                                  |
--   |     |                                                                 |
--   |     | 2. Forwards a generic DAP request to the adapter.               |
--   |     V                                                                 |
--   |  [ codelldb Adapter (running on host) ]                               |
--   |     |                                                                 |
--   |     | 3. Translates the request into the GDB Remote Protocol          |
--   |     |    that lldb-server understands.                                |
--   |     V                                                                 |
--   +-----------------------------------------------------------------------+
--
--                 ||
--                 || 4. Docker Port Mapping (from docker-compose.yml)
--                 ||    The command travels via TCP (e.g., localhost:12345)
--                 ||    from the host into the container.
--                 ||
--
--   DOCKER CONTAINER (Isolated Environment)
--   +-----------------------------------------------------------------------+
--   |     ^                                                                 |
--   |  [ lldb-server ]                                                      |
--   |     |                                                                 |
--   |     | 5. Receives the GDB command and tells your C++ app what to do.  |
--   |     V                                                                 |
--   |  [ Your C++ Application ]                                             |
--   |     |                                                                 |
--   |     '-> 6. The breakpoint is set in the application's process.        |
--   |                                                                       |
--   +-----------------------------------------------------------------------+
--
--]]

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    -- Mason integration for automatic adapter setup
    "jay-babu/mason-nvim-dap.nvim",
  },
  config = function()
    local dap = require("dap")

    -- Define the codelldb adapter.
    -- This tells nvim-dap how to start the codelldb process, which acts as a DAP server.
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}", -- A placeholder that nvim-dap will replace with a free port.
      executable = {
        -- Use vim.fn.stdpath to get the Mason binary path reliably.
        command = vim.fn.stdpath("data").. "/mason/bin/codelldb",
        args = { "--port", "${port}" },
      },
    }

    dap.configurations.cpp = {
      {
        name = "Attach to Container (LLDB)", -- A user-friendly name for the debug launcher menu
        type = "codelldb",                  -- Links this configuration to the 'codelldb' adapter defined above
        request = "attach",                 -- Specifies that we are attaching to an existing process

        -- Path to the executable on the HOST machine.
        -- This is required for the local codelldb adapter to load debug symbols.
        program = function()
        return vim.fn.input('Path to local executable: ', vim.fn.getcwd().. '/', 'file')
        end,

        -- The PID of the process to attach to INSIDE the container.
        pid = function()
        return tonumber(vim.fn.input('Enter PID of process in container: '))
        end,

        cwd = "${workspaceFolder}",
        stopOnEntry = false,

        -- CRITICAL: This tells codelldb where to find the remote lldb-server.
        -- 'localhost:12345' works because of the port mapping in docker-compose.yml.
        miDebuggerServerAddress = "localhost:12345",

        -- CRITICAL: This maps source file paths between the host and the container.
        -- It tells the debugger how to find the local source file when the remote
        -- process stops at a location specified by a remote path.
        sourceMap = {
        ["/home/<docker_user>"] = "${workspaceFolder}", -- EDIT THIS
        },
        -- For older versions of the adapter, the key might be `pathMappings`.
        -- pathMappings = {
        --   {
        --     localRoot = "${workspaceFolder}",
        --     remoteRoot = "/app",
        --   },
        -- },
      },
    }
  end,
}
