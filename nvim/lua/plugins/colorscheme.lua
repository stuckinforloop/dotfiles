-- Colorscheme: Rex themes (see lua/rex/init.lua), no italics, follows macOS light/dark.

-- Remove italics from every highlight group, including groups that plugins
-- define themselves (tokyonight's own groups are handled in on_highlights below).
local function strip_italics()
  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if hl.italic and not hl.link then
      hl.italic = nil
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("no_italics", { clear = true }),
  callback = function()
    vim.schedule(strip_italics) -- after plugins' own ColorScheme handlers
  end,
})
vim.api.nvim_create_autocmd("User", { pattern = "VeryLazy", once = true, callback = strip_italics })

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true, -- let the terminal (Rex) background show through
      styles = {
        comments = { italic = false },
        keywords = { italic = false },
        sidebars = "transparent",
        floats = "transparent",
      },
      on_colors = function(c)
        require("rex").on_colors(c)
      end,
      on_highlights = function(hls)
        for _, hl in pairs(hls) do
          if type(hl) == "table" then
            hl.italic = nil
          end
        end
      end,
    },
  },

  -- bufferline builds its own highlight groups; its preset turns italics off there
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.style_preset = require("bufferline").style_preset.no_italic
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "rex" },
  },

  -- Polls macOS appearance and sets 'background'; `:colorscheme rex` reloads itself
  -- with the matching variant whenever 'background' changes.
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 900,
    opts = {
      update_interval = 3000,
      fallback = "dark",
    },
  },
}
