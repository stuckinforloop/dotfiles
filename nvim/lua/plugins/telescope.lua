return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-telescope/telescope-file-browser.nvim",
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        { "kkharji/sqlite.lua" },
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local fb_actions = require("telescope").load_extension("file_browser")
        telescope.load_extension("fzf")
        telescope.load_extension("git_worktree")

        local function telescope_buffer_dir()
            return vim.fn.expand("%:p:h")
        end

        telescope.setup({
            defaults = {
                path_display = { "truncate " },
                wrap_results = true,
                layout_strategy = "horizontal",
                layout_config = { prompt_position = "top" },
                sorting_strategy = "ascending",
                winblend = 0,
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
                        ["<C-j>"] = actions.move_selection_next,     -- move to next result
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    },
                },
            },
            pickers = {
                diagnostics = {
                    theme = "ivy",
                    initial_mode = "normal",
                    layout_config = {
                        preview_cutoff = 9999,
                    }
                },
            },
            extensions = {
                file_browser = {
                    theme = "dropdown",
                    mappings = {
                        ["n"] = {
                            -- your custom normal mode mappings
                            ["N"] = fb_actions.create,
                            ["h"] = fb_actions.goto_parent_dir,
                            ["/"] = function()
                                vim.cmd("startinsert")
                            end,
                        },
                    },
                },
            },
        })

        vim.keymap.set("n", "sf", function()
            telescope.extensions.file_browser.file_browser({
                path = "%:p:h",
                cwd = telescope_buffer_dir(),
                respect_gitignore = true,
                hidden = true,
                grouped = true,
                previewer = false,
                initial_mode = "normal",
                layout_config = { height = 40 },
            })
        end)
    end,
}
