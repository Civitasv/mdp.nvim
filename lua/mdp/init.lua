local Path = require("plenary.path")
local quickfix = require("mdp.quickfix")
local watch = require("mdp.watch")

local M = {
  file = nil,
  buffer = nil,
  cache_dir = vim.fn.expand("~") .. "/.cache/mdp/",
  pdfviewer = "Skim",
  template = "default",
  state = ""
}

local function file_exists(path)
  local file = Path:new(path)
  if not file:exists() then
    return false
  end
  return true
end

local function mkdir(dir)
  local _dir = Path:new(dir)
  _dir:mkdir({ parents = true, exists_ok = true })
end

function M.setup(opts)
  if not file_exists(M.cache_dir) then
    mkdir(M.cache_dir)
  end

  if opts.pdfviewer then
    M.pdfviewer = opts.pdfviewer
  end
  if opts.template then
    M.template = opts.template
  end
end

function M.convert(file, on_success)
  M.state = "[Mdp] Compiling"
  local output = M.cache_dir .. file .. ".pdf"
  local cmd = "pandoc"
  local args = { file, "--pdf-engine=xelatex", "--template=" .. M.template, "-o", output }

  quickfix.run(cmd, args, ".", {
    show = "only_on_error",
    size = 10,
    position = "belowright"
  }, function()
    M.state = "[Mdp] ✍️"
    if on_success then
      on_success(output)
    end
  end)
end

function M.live_preview()
  M.file = vim.fn.expand("%:t")
  M.buffer = vim.api.nvim_get_current_buf()

  -- We firstly convert it, and open it in the PDF viewer.
  M.convert(M.file, function(output)
    local cmd = "open"
    local args = { "-a", M.pdfviewer, output }
    quickfix.run(cmd, args, ".", {
      show = "only_on_error",
      size = 10,
      position = "belowright"
    })
  end)

  -- Then watch it, when file changes, we convert it again.
  watch.watch_file(M.file, function()
    M.convert(M.file)
  end)

  -- Add autocommands, when buffer closed, remove all the watchers.
  local group = vim.api.nvim_create_augroup("mdp", { clear = true })
  vim.api.nvim_create_autocmd("BufUnload", {
    group = group,
    buffer = M.buffer,
    callback = function()
      M.stop()

      vim.api.nvim_del_augroup_by_id(group)
    end,
  })
end

function M.stop()
  -- Firstly, don't watch it again.
  watch.stop()

  -- Then, close the PDF viewer.
  local cmd = "pkill"
  local args = { "-x", M.pdfviewer }
  quickfix.run(cmd, args, ".", {
    show = "only_on_error",
    size = 10,
    position = "belowright"
  })
  M.state = ""
end

function M.status()
  return M.state
end

return M
