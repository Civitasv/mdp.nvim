local mdp = require("mdp")

vim.api.nvim_create_user_command(
  "Mdp",
  mdp.live_preview,
  {
    nargs = 0,
    desc = "Preview current markdown file"
  }
)

