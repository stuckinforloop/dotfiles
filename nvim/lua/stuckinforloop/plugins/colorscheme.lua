return {
    "ellisonleao/gruvbox.nvim",
    dependencies = {
        "xiyaowong/transparent.nvim",
        "felipeagc/fleet-theme-nvim"
    },
    config = function()
        require("gruvbox").setup({
            bold = true,
            dim_inactive = true,
            invert_selection = true,
            italic = {
                strings = false,
                emphasis = false,
                comments = false,
                operators = false,
                folds = false,
            },
            transparent_mode = true,
            terminal_colors = true,
            underline = false,
        })

        function ColorMyPencils(color)
            color = color or "gruvbox"
            vim.cmd.colorscheme(color)

            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
            vim.api.nvim_set_hl(0, "Select", { bg = "none" })
            vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })
            vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })

            -- local links = {
            --     ['@lsp.type.namespace'] = '@namespace',
            --     ['@lsp.type.type'] = '@type',
            --     ['@lsp.type.class'] = '@type',
            --     ['@lsp.type.enum'] = '@type',
            --     ['@lsp.type.interface'] = '@type',
            --     ['@lsp.type.struct'] = '@structure',
            --     ['@lsp.type.parameter'] = '@parameter',
            --     ['@lsp.type.variable'] = '@variable',
            --     ['@lsp.type.property'] = '@property',
            --     ['@lsp.type.enumMember'] = '@constant',
            --     ['@lsp.type.function'] = '@function',
            --     ['@lsp.type.method'] = '@method',
            --     ['@lsp.type.macro'] = '@macro',
            --     ['@lsp.type.decorator'] = '@function',
            -- }
            -- for newgroup, oldgroup in pairs(links) do
            --     vim.api.nvim_set_hl(0, newgroup, { link = oldgroup, default = true })
            -- end

            require("transparent").setup({
                extra_groups = {
                    "NormalFloat", -- plugins which have float panel such as Lazy, Mason, LspInfo
                },
            })
        end

        ColorMyPencils()
    end,
}
