wget https://git-annex.branchable.com/install/Android/git-annex-install
MY_WD=$(pwd)

source git-annex-install || printf "failed\n"

cd "$MY_WD"
mv ~/git-annex.linux ./
