return {
  -- no startup dashboard; `nvim` opens an empty buffer
  {
    "folke/snacks.nvim",
    opts = { dashboard = { enabled = false } },
  },

  -- classic cmdline at the bottom instead of the centred popup
  {
    "folke/noice.nvim",
    opts = {
      cmdline = { view = "cmdline" },
      presets = { command_palette = false }, -- only positions the popup layout
    },
  },
}
