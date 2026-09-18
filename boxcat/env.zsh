# Where every Boxcat repo lives on a host — one file, every shell, every machine. `config/setup.sh`
# symlinks it to ~/.config/boxcat/env.zsh and `.zshenv` sources it for all shells, so pm2 and
# non-login ssh see the same values an interactive shell does. Server-only vars are ~/.zshenv.local's,
# written by `setup-server.sh`; secrets never go here — ~/.zshenv.local keeps those too.

export MEOW_ROOT="$HOME/Develop"
export MEOW_CLIENT="$MEOW_ROOT/meow-tower"
export MEOW_REPO="$MEOW_ROOT/meow-tower"
export MEOW_TOOLBOX="$MEOW_ROOT/meow-toolbox"
export MEOW_LANGPACK="$MEOW_ROOT/meow-langpack"
export MEOW_DEV_MEDIA="$MEOW_ROOT/meow-dev-media"
export MEOW_ASSETS="$MEOW_ROOT/meow-assets"
export MEOW_ASSETBUNDLE_CACHE="$MEOW_ROOT/meow-assetbundle-cache"
export MEOW_MIGRATION_TEST_DATA="$MEOW_ROOT/meow-migration-test-data"
export MEOW_DEFS="$MEOW_ROOT/meow-defs"
export MEOW_INFRA="$MEOW_ROOT/meow-infra"
export MEOW_SERVER="$MEOW_ROOT/meow-game-server"
export MEOW_CRED="$HOME/.config/boxcat/credentials"
export CONFIG_REPO="$MEOW_ROOT/config"
export ALFREDO_REPO="$MEOW_ROOT/alfredo"
export UNITY_EDITOR_DECOMPILED="$MEOW_ROOT/UnityDecompiled"
export WORKTREE_ROOT="$HOME/.worktree-pool"

# Follows the client's editor: a literal drifts on every Unity upgrade, and a stale one silently
# resolves reference assemblies from the old install (decompiles, fork rebuilds) rather than failing.
[[ -r "$MEOW_CLIENT/ProjectSettings/ProjectVersion.txt" ]] \
    && read -r _ UNITY_VER < "$MEOW_CLIENT/ProjectSettings/ProjectVersion.txt" \
    && export UNITY_VER \
    && export UNITY="/Applications/Unity/Hub/Editor/$UNITY_VER/Unity.app/Contents/MacOS/Unity"
