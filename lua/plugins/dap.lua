return {
  "mfussenegger/nvim-dap",
  opts = function(_, opts)
    local dap = require("dap")

    -- LLDB server adapter configuration for remote debugging
    dap.adapters.lldb = {
      type = "server",
      host = "127.0.0.1", -- Your host machine connects via localhost to the exposed container port
      port = 1234,        -- Port that matches `lldb-server gdbserver :1234`
      name = "lldb",
    }

    -- Debugging configuration for C++ (or Python programs invoked by LLDB server)
    dap.configurations.cpp = {
      {
        name = "Debug Program in Docker",    -- Name of the debug session
        type = "lldb",                       -- Use the LLDB adapter defined above
        request = "launch",                  -- Launch request for starting the debugging session
        program = function()
          -- Remote debugging mode, no need for a full local binary path
          return vim.fn.input("Path to executable in container (optional): ", "", "file")
        end,
        cwd = "${workspaceFolder}",          -- Set current working directory inside the container as workspace
        stopOnEntry = true,                  -- Stop the program at its entry point for initial setup
        args = {},                           -- No command-line args since your Python script handles them
      },
    }
  end,
}
