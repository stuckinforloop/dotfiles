return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function(_, opts)
      require("solarized-osaka").setup(opts)

      local function clear_bg(groups)
        for _, group in ipairs(groups) do
          vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
        end
      end

      local function style_selection()
        -- Keep selection visible with a neutral tint (not the default blue)
        local selected_bg = "#4c566a"
        local selected_fg = "#eceff4"

        vim.api.nvim_set_hl(0, "Visual", { bg = selected_bg, fg = "NONE", ctermbg = 8, ctermfg = "NONE" })
        vim.api.nvim_set_hl(0, "VisualNOS", { bg = selected_bg, fg = "NONE", ctermbg = 8, ctermfg = "NONE" })
        vim.api.nvim_set_hl(0, "CursorLine", { bg = selected_bg, ctermbg = 8 })

        -- Popup/command completion selected item highlighting
        vim.api.nvim_set_hl(0, "PmenuSel", { bg = selected_bg, fg = selected_fg, bold = true, ctermbg = 8, ctermfg = 15 })
        vim.api.nvim_set_hl(0, "PmenuMatchSel", { bg = selected_bg, fg = selected_fg, bold = true, ctermbg = 8, ctermfg = 15 })
        vim.api.nvim_set_hl(0, "PmenuKindSel", { bg = selected_bg, fg = selected_fg, bold = true, ctermbg = 8, ctermfg = 15 })
        vim.api.nvim_set_hl(0, "PmenuExtraSel", { bg = selected_bg, fg = selected_fg, bold = true, ctermbg = 8, ctermfg = 15 })
        vim.api.nvim_set_hl(0, "WildMenu", { bg = selected_bg, fg = selected_fg, bold = true, ctermbg = 8, ctermfg = 15 })

        -- Blink cmdline/completion groups
        vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = selected_bg, fg = selected_fg, bold = true, ctermbg = 8, ctermfg = 15 })
        vim.api.nvim_set_hl(0, "BlinkCmpMenu", { link = "Pmenu" })

        -- Match old config behavior: menu background should not introduce its own tint.
        vim.api.nvim_set_hl(0, "Pmenu", { link = "Normal" })
      end

      local transparent_groups = {
        "Normal",
        "NormalNC",
        "NormalFloat",
        "FloatBorder",
        "SignColumn",
        "FoldColumn",
        "EndOfBuffer",
        "CursorLine",
        "CursorLineNr",
        "LineNr",
        "WinSeparator",
        "StatusLine",
        "StatusLineNC",
        "TabLine",
        "TabLineFill",
        "TabLineSel",
        "Pmenu",
        "PmenuSel",
        "PmenuSbar",
        "PmenuThumb",
        "PmenuBorder",
        "PmenuKind",
        "PmenuKindSel",
        "PmenuExtra",
        "PmenuExtraSel",
        "PmenuMatch",
        "PmenuMatchSel",
        "Search",
        "IncSearch",
        "CurSearch",
        "Substitute",
        "ColorColumn",
        "QuickFixLine",
        "CursorColumn",
        "WildMenu",
      }

      local function apply_transparency()
        clear_bg(transparent_groups)
        style_selection()
      end

      local transparent_group = vim.api.nvim_create_augroup("transparent_colors", { clear = true })

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = transparent_group,
        callback = apply_transparency,
      })

      vim.api.nvim_create_autocmd("CmdlineEnter", {
        group = transparent_group,
        callback = function()
          vim.schedule(apply_transparency)
        end,
      })

      vim.cmd("colorscheme solarized-osaka")
      apply_transparency()
      vim.schedule(apply_transparency)
    end,
  },
}
