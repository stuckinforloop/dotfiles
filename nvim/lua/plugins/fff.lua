local function backend_path()
  local ext = (vim.uv.os_uname().sysname == "Windows_NT") and "dll" or ((vim.uv.os_uname().sysname == "Darwin") and "dylib" or "so")
  return vim.fn.stdpath("data") .. "/lazy/fff.nvim/target/release/libfff_nvim." .. ext
end

local function download_prebuilt_from_release()
  local sys = vim.uv.os_uname().sysname
  local machine = vim.uv.os_uname().machine

  local asset = nil
  if sys == "Darwin" and machine == "arm64" then
    asset = "aarch64-apple-darwin.dylib"
  elseif sys == "Darwin" and (machine == "x86_64" or machine == "amd64") then
    asset = "x86_64-apple-darwin.dylib"
  elseif sys == "Linux" and machine == "x86_64" then
    asset = "x86_64-unknown-linux-gnu.so"
  elseif sys == "Linux" and machine == "aarch64" then
    asset = "aarch64-unknown-linux-gnu.so"
  end

  if not asset then
    vim.notify("fff.nvim: no known prebuilt asset for " .. sys .. "/" .. machine, vim.log.levels.WARN)
    return false
  end

  local out = backend_path()
  vim.fn.mkdir(vim.fn.fnamemodify(out, ":h"), "p")

  if vim.uv.fs_stat(out) then
    return true
  end

  if vim.fn.executable("gh") == 1 then
    local cmd = string.format(
      "gh release download v0.4.0 -R dmtrKovalenko/fff.nvim -p '%s' -O '%s' --clobber",
      asset,
      out
    )
    vim.fn.system(cmd)
    return vim.v.shell_error == 0 and vim.uv.fs_stat(out) ~= nil
  end

  return false
end

return {
  {
    "dmtrKovalenko/fff.nvim",
    version = "v0.4.0",
    lazy = false,
    build = function()
      if download_prebuilt_from_release() then
        return
      end

      local ok = pcall(function()
        require("fff.download").download_or_build_binary()
      end)

      if not ok then
        vim.notify(
          "fff.nvim backend install failed. Install rustup/cargo or download release asset manually.",
          vim.log.levels.WARN
        )
      end
    end,
    opts = {
      prompt = "󰍉 ",
      title = "Files",
    },
    config = function(_, opts)
      require("fff").setup(opts)
    end,
  },
}
