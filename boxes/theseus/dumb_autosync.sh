cd ~/; while true; do rsync -avz --delete -e "ssh -p 443" ./dots/ bitwarden.beepboop.systems:~/dot_testing/ -vvv; sleep 1; done
