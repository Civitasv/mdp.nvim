local M = {
  event = vim.loop.new_fs_event()
}

function M.watch_file(fname, on_change)
  local fullpath = vim.api.nvim_call_function('fnamemodify', { fname, ':p' })

  M.event:start(fullpath, {}, vim.schedule_wrap(function()
    if on_change then
      on_change(fname)
    end
    M.event:stop()
    M.watch_file(fname, on_change)
  end))
end

function M.stop()
  M.event:stop()
end

return M
