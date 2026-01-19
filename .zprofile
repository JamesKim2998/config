# .zshenv - all shells (keep minimal, runs before path_helper)
# .zprofile - login shells (PATH, env vars - inherited by subshells)
# .zshrc - interactive shells (aliases, functions, prompt - not inherited)

# zsh completions
fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)

# editors
export EDITOR=$HOMEBREW_PREFIX/bin/nvim

# claude code
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# fzf (Kanagawa colors)
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#2d4f67,bg:#1f1f28,spinner:#c8c093,hl:#c34043 \
  --color=fg:#dcd7ba,header:#c34043,info:#957fb8,pointer:#c8c093 \
  --color=marker:#7e9cd8,fg+:#dcd7ba,prompt:#957fb8,hl+:#e82424 \
  --color=selected-bg:#2d4f67 \
  --color=border:#727169,label:#dcd7ba"

# zoxide
export _ZO_FZF_OPTS='+e --height=40% --layout=reverse --border --no-sort'
