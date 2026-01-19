# .zshenv - all shells (keep minimal, runs before path_helper)
# .zprofile - login shells (PATH, env vars - inherited by subshells)
# .zshrc - interactive shells (aliases, functions, prompt - not inherited)

# core
export MEOW_ROOT="$HOME/Develop"

# homebrew (baked from: /opt/homebrew/bin/brew shellenv)
BREW=/opt/homebrew
export HOMEBREW_PREFIX="$BREW"
export HOMEBREW_CELLAR="$BREW/Cellar"
export HOMEBREW_REPOSITORY="$BREW"
export PATH="$BREW/bin:$BREW/sbin:$PATH"
export MANPATH="$BREW/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="$BREW/share/info:${INFOPATH:-}"
export HOMEBREW_NO_UPDATE_REPORT_NEW=1
export HOMEBREW_NO_ENV_HINTS=1

# path
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="$BREW/opt/openjdk/bin:$PATH"
export PATH="$BREW/opt/trash-cli/bin:$PATH"
export PATH="$HOME/Library/Android/sdk/emulator:$HOME/Library/Android/sdk/platform-tools:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# dotnet
export DOTNET_ROOT="$HOME/.dotnet"

# local overrides (credentials, machine-specific)
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
