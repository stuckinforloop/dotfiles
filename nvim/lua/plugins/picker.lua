return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>gl",
        function()
          Snacks.picker.git_log({
            finder = "git_log",
            format = "git_log",
            preview = "git_show",
            confirm = "git_checkout",
            -- layout = "vertical",
          })
        end,
        desc = "Git Log",
      },
      {
        "<leader>gb",
        function()
          Snacks.picker.git_branches({
            layout = "select",
          })
        end,
        desc = "Branches",
      },
      -- File picker
      {
        "<leader>ff",
        function()
          Snacks.picker.files({
            finder = "files",
            format = "file",
            show_empty = true,
            supports_live = true,
            -- In case you want to override the layout for this keymap
            -- layout = "vscode",
          })
        end,
        desc = "Find Files",
      },
      -- Navigate my buffers
      {
        "<S-h>",
        function()
          Snacks.picker.buffers({
            finder = "buffers",
            format = "buffer",
            hidden = false,
            unloaded = true,
            current = true,
            sort_lastused = true,
            win = {
              input = {
                keys = {
                  ["d"] = "bufdelete",
                },
              },
              list = { keys = { ["d"] = "bufdelete" } },
            },
          })
        end,
        desc = "[P]Snacks picker buffers",
      },
    },
    opts = {
      picker = {
        layout = {
          preset = "ivy",
          cycle = false,
        },
        layouts = {
          ivy = {
            layout = {
              box = "vertical",
              backdrop = false,
              row = -1,
              width = 0,
              height = 0.5,
              border = "top",
              title = " {title} {live} {flags}",
              title_pos = "left",
              { win = "input", height = 1, border = "bottom" },
              {
                box = "horizontal",
                { win = "list",    border = "none" },
                { win = "preview", title = "{preview}", width = 0.5, border = "left" },
              },
            },
          },
          vertical = {
            layout = {
              backdrop = false,
              width = 0.8,
              min_width = 80,
              height = 0.8,
              min_height = 30,
              box = "vertical",
              border = "rounded",
              title = "{title} {live} {flags}",
              title_pos = "center",
              { win = "input",   height = 1,          border = "bottom" },
              { win = "list",    border = "none" },
              { win = "preview", title = "{preview}", height = 0.4,     border = "top" },
            },
          },
        },
        matcher = {
          frecency = true,
        },
        win = {
          input = {
            keys = {
              -- to close the picker on ESC instead of going to normal mode,
              -- add the following keymap to your config
              ["<Esc>"] = { "close", mode = { "n", "i" } },
              -- I'm used to scrolling like this in LazyGit
              ["J"] = { "preview_scroll_down", mode = { "i", "n" } },
              ["K"] = { "preview_scroll_up", mode = { "i", "n" } },
              ["H"] = { "preview_scroll_left", mode = { "i", "n" } },
              ["L"] = { "preview_scroll_right", mode = { "i", "n" } },
            },
          },
        },
        formatters = {
          file = {
            filename_first = true, -- display filename before the file path
            truncate = 80,
          },
        },
      },
    },
  },
}
