# Deploy: push and pull on server
deploy:
    git push
    ssh -i $MACMINI_SSH_KEY $MACMINI_DEST "cd ~/Develop/config && git pull"
