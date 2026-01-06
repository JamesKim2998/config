# Deploy: push and pull on server
deploy:
    git push
    ssh -i ~/.ssh/james-macmini jameskim@192.168.219.122 "cd ~/Develop/config && git pull"
