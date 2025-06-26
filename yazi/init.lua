-- https://github.com/yazi-rs/plugins/tree/main/full-border.yazi
require("full-border"):setup()

require("zoxide"):setup({
  picker     = "fzf",   -- keep the interactive fzf list (default)
  update_db  = true,    -- auto-remember every dir you visit
})

-- https://github.com/yazi-rs/plugins/tree/main/git.yazi
require("git"):setup()

