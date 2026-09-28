-- Debugging via nvim-dap. Adapters come from Mason (debugpy, netcoredbg; see
-- run_once_after_04-nvim.sh.tmpl). Keys are all under <leader>d: F10/F11 are
-- swallowed by Windows Terminal (F11 = fullscreen), so no F-key bindings.
local function dap(fn, ...)
    local args = { ... }
    return function() require("dap")[fn](unpack(args)) end
end

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
            "mfussenegger/nvim-dap-python",
        },
        keys = {
            { "<leader>dc", dap("continue"), desc = "Debug: start / continue" },
            { "<leader>do", dap("step_over"), desc = "Debug: step over" },
            { "<leader>di", dap("step_into"), desc = "Debug: step into" },
            { "<leader>dO", dap("step_out"), desc = "Debug: step out" },
            { "<leader>db", dap("toggle_breakpoint"), desc = "Debug: toggle breakpoint" },
            {
                "<leader>dB",
                function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,
                desc = "Debug: conditional breakpoint",
            },
            { "<leader>dC", dap("run_to_cursor"), desc = "Debug: run to cursor" },
            { "<leader>dl", dap("run_last"), desc = "Debug: run last" },
            { "<leader>dt", dap("terminate"), desc = "Debug: terminate" },
            { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: toggle REPL" },
            { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: toggle UI" },
            { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Debug: evaluate" },
        },
        config = function()
            local d, dapui = require("dap"), require("dapui")
            dapui.setup()
            d.listeners.before.attach.dapui_config = function() dapui.open() end
            d.listeners.before.launch.dapui_config = function() dapui.open() end
            d.listeners.before.event_terminated.dapui_config = function() dapui.close() end
            d.listeners.before.event_exited.dapui_config = function() dapui.close() end

            local mason = vim.fn.stdpath("data") .. "/mason"

            -- Python: debugpy runs from Mason's venv; the debuggee uses the project's
            -- .venv / venv / $VIRTUAL_ENV python (nvim-dap-python resolves it).
            require("dap-python").setup(mason .. "/packages/debugpy/venv/bin/python")

            -- C#: netcoredbg. Build first (dotnet build), then pick the dll.
            d.adapters.coreclr = {
                type = "executable",
                command = mason .. "/bin/netcoredbg",
                args = { "--interpreter=vscode" },
            }
            d.configurations.cs = {
                {
                    type = "coreclr",
                    name = "Launch .NET dll",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
                    end,
                },
            }
        end,
    },
}
