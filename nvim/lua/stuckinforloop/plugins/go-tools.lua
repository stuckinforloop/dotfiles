return {
    "ray-x/go.nvim",
    dependencies = {
        "ray-x/guihua.lua",
        "neovim/nvim-lspconfig",
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("go").setup({
            lsp_inlay_hints = {
                enable = true,
                style = 'eol',
                only_current_line = false,
                only_current_line_autocmd = "CursorHold",
                show_variable_name = true,
                parameter_hints_prefix = "󰊕 ",
                show_parameter_hints = true,
                other_hints_prefix = "=> ",
                max_len_align = false,
                max_len_align_padding = 1,
                right_align = false,
                right_align_padding = 6,
                highlight = "Comment",
            },
        })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
}
