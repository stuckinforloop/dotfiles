return {
	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		dependencies = {
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
			"leoluz/nvim-dap-go",
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
		},
		keys = {
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle breakpoint",
			},
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Conditional breakpoint",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step into",
			},
			{
				"<leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "Step over",
			},
			{
				"<leader>dO",
				function()
					require("dap").step_out()
				end,
				desc = "Step out",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.open()
				end,
				desc = "Open DAP REPL",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "Run last debug session",
			},
			{
				"<leader>dt",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate debug session",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle()
				end,
				desc = "Toggle DAP UI",
			},
			{
				"<leader>dgt",
				function()
					require("dap-go").debug_test()
				end,
				desc = "Debug Go test",
			},
			{
				"<leader>dgl",
				function()
					require("dap-go").debug_last_test()
				end,
				desc = "Debug last Go test",
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			require("mason-nvim-dap").setup({
				ensure_installed = { "delve" },
				automatic_installation = true,
			})

			dapui.setup()

			require("nvim-dap-virtual-text").setup({
				commented = true,
			})

			require("dap-go").setup()

			vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "DiagnosticSignError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "DiagnosticSignWarn" })
			vim.fn.sign_define("DapLogPoint", { text = " ", texthl = "DiagnosticSignInfo" })
			vim.fn.sign_define("DapStopped", { text = " ", texthl = "DiagnosticSignHint" })
			vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "DiagnosticSignError" })

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},
}
