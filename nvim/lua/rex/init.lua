-- Rex colorscheme: tokyonight's highlight groups driven by Rex's terminal themes.
--   dark  = Rex "Cobalt Foundry"     (Workspace.darkThemeID  = cobalt-foundry)
--   light = Rex "Porcelain Morning"  (Workspace.lightThemeID = porcelain-morning)
-- Source: /Applications/Rex Beta.app/.../SuperUI_SuperDesignTokens.bundle/.../themes.json
-- Used via `:colorscheme rex`; the variant follows 'background'.
local M = {}

-- 16 ANSI colors exactly as Rex defines them (used for :terminal)
local ansi = {
  dark = {
    "#1a2129",
    "#e57373",
    "#81b366",
    "#d4a95f",
    "#4f95e0",
    "#9d85cf",
    "#56b3c4",
    "#a2b0be",
    "#56626f",
    "#ef8f8f",
    "#9cc983",
    "#e5c07e",
    "#74aeec",
    "#b5a0e0",
    "#78cbda",
    "#e2eaf2",
  },
  light = {
    "#2e3a42",
    "#c74e42",
    "#3d8a4e",
    "#b07c22",
    "#2c6fbe",
    "#8455a8",
    "#22808a",
    "#cfd8dd",
    "#6d7d88",
    "#e0604f",
    "#4aa55f",
    "#cf9226",
    "#3d85d8",
    "#9c6ac2",
    "#2d99a5",
    "#ffffff",
  },
}

-- tokyonight palette slots filled from Rex's ANSI + semantic tokens.
-- Comments name the Rex token each value comes from.
M.palettes = {
  dark = {
    bg = "#141920", -- terminalBackground
    bg_dark = "#10151c", -- canvas (sidebars, floats, statusline)
    bg_dark1 = "#0c1016",
    bg_highlight = "#20252c", -- surfaceRaised (cursorline)
    fg = "#c2cedb", -- content
    fg_dark = "#a2b0be", -- ansi 7
    fg_gutter = "#424a53", -- stroke
    comment = "#6f7a86", -- between contentTertiary and contentSecondary
    dark3 = "#56626f", -- ansi 8
    dark5 = "#828c97", -- contentSecondary
    terminal_black = "#56626f", -- ansi 8
    blue = "#4f95e0", -- ansi 4
    blue0 = "#2a4f7a", -- search background
    blue1 = "#56b3c4", -- ansi 6
    blue2 = "#4fa8ff", -- accent
    blue5 = "#78cbda", -- ansi 14
    blue6 = "#a8dde8",
    blue7 = "#1a293b", -- accentContainer
    cyan = "#74aeec", -- ansi 12
    green = "#81b366", -- ansi 2
    green1 = "#78cbda", -- ansi 14
    green2 = "#56b3c4", -- ansi 6
    magenta = "#b5a0e0", -- ansi 13
    magenta2 = "#ef8f8f", -- ansi 9
    purple = "#9d85cf", -- ansi 5
    orange = "#e0956a", -- red/yellow blend (Rex has no orange)
    red = "#ef8f8f", -- ansi 9
    red1 = "#e57373", -- danger
    teal = "#56b3c4", -- ansi 6
    yellow = "#d4a95f", -- warning
    git = { add = "#81b366", change = "#4f95e0", delete = "#e57373" },
    _rex = { visual = "#1f3a5c", ansi = ansi.dark }, -- selectionBackground
  },
  light = {
    bg = "#f8fbfc", -- terminalBackground
    bg_dark = "#edeff0", -- surfaceSubtle (sidebars, floats, statusline)
    bg_dark1 = "#e3e6e8",
    bg_highlight = "#ebf0f3", -- cursorline
    fg = "#2e3a42", -- content
    fg_dark = "#4a565e",
    fg_gutter = "#cfd4d6", -- stroke
    comment = "#6d7d88", -- ansi 8
    dark3 = "#838b91", -- contentTertiary
    dark5 = "#656e75", -- contentSecondary
    terminal_black = "#6d7d88", -- ansi 8
    blue = "#2c6fbe", -- ansi 4
    blue0 = "#a9cdee", -- search background
    blue1 = "#22808a", -- ansi 6
    blue2 = "#176dbf", -- accent
    blue5 = "#1f7f8c",
    blue6 = "#22808a",
    blue7 = "#e6eef6", -- accentContainer
    cyan = "#2b6dbc", -- info
    green = "#2f7a41", -- success
    green1 = "#22808a", -- ansi 6
    green2 = "#3d8a4e", -- ansi 2
    magenta = "#9c6ac2", -- ansi 13
    magenta2 = "#c74e42", -- ansi 1
    purple = "#8455a8", -- ansi 5
    orange = "#b5612a", -- red/yellow blend (Rex has no orange)
    red = "#c74e42", -- ansi 1
    red1 = "#ba4439", -- danger
    teal = "#22808a", -- ansi 6
    yellow = "#926300", -- warning
    git = { add = "#3d8a4e", change = "#2c6fbe", delete = "#c74e42" },
    _rex = { visual = "#cde3f5", ansi = ansi.light }, -- selectionBackground
  },
}

-- register as tokyonight styles "rex_dark" / "rex_light" (fresh copy per load)
local styles = require("tokyonight.colors").styles
for variant, palette in pairs(M.palettes) do
  styles["rex_" .. variant] = function()
    return vim.deepcopy(palette)
  end
end

function M.style()
  return vim.o.background == "light" and "rex_light" or "rex_dark"
end

-- tokyonight derives some colors after reading the palette; pin those to Rex's values.
-- Wired up through tokyonight's `on_colors` (see lua/plugins/colorscheme.lua).
function M.on_colors(c)
  local rex = c._rex
  if not rex then
    return
  end
  c.bg_visual = rex.visual
  -- stylua: ignore
  c.terminal = {
    black = rex.ansi[1], red = rex.ansi[2], green = rex.ansi[3], yellow = rex.ansi[4],
    blue = rex.ansi[5], magenta = rex.ansi[6], cyan = rex.ansi[7], white = rex.ansi[8],
    black_bright = rex.ansi[9], red_bright = rex.ansi[10], green_bright = rex.ansi[11],
    yellow_bright = rex.ansi[12], blue_bright = rex.ansi[13], magenta_bright = rex.ansi[14],
    cyan_bright = rex.ansi[15], white_bright = rex.ansi[16],
  }
end

function M.load()
  require("tokyonight.theme").setup({ style = M.style() })
  -- so that changing 'background' re-runs `:colorscheme rex`
  vim.g.colors_name = "rex"
end

return M
