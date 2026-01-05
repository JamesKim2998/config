# Launch Claude Code
cc:
    claude --model opus --dangerously-skip-permissions

# Deploy: push and pull on server
deploy:
    git push
    ssh -i ~/.ssh/james-macmini jameskim@192.168.219.122 "cd ~/Develop/config && git pull"
