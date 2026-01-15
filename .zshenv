# .zshenv - all shells (keep minimal, runs before path_helper)
# .zprofile - login shells (PATH, env vars - inherited by subshells)
# .zshrc - interactive shells (aliases, functions, prompt - not inherited)

# local overrides (credentials, machine-specific)
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
