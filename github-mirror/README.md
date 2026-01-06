# GitHub Mirror

Local git mirror on Mac Mini for fast fetch (~60ms vs ~900ms from GitHub).

## How It Works

1. **LaunchAgent** syncs from GitHub every 30 seconds
2. **Post-receive hook** pushes to GitHub when you push to mirror

## Setup

Run on Mac Mini:

```sh
# Create mirror directory
mkdir -p ~/Develop/github-mirror

# Clone repo as mirror
git clone --mirror git@github.com:studio-boxcat/meow-tower.git ~/Develop/github-mirror/meow-tower.git

# Add post-receive hook
cat > ~/Develop/github-mirror/meow-tower.git/hooks/post-receive << 'EOF'
#!/bin/bash
git push github --all &
git push github --tags &
EOF
chmod +x ~/Develop/github-mirror/meow-tower.git/hooks/post-receive

# Add github remote for pushing
git -C ~/Develop/github-mirror/meow-tower.git remote add github git@github.com:studio-boxcat/meow-tower.git
```

## Client Setup

Use full hostname in remote URL (for GUI apps like Fork):

```sh
git remote set-url origin jameskim@macmini.studioboxcat.com:Develop/github-mirror/meow-tower.git
```

## Files

| File | Purpose |
|------|---------|
| `sync.sh` | Syncs all mirror repos from GitHub |
| `com.boxcat.github-mirror.plist` | LaunchAgent for 30-second sync |
