# fetch private data repository and deploy

mkdir -p $HOME/git/
git clone https://git.beepboop.systems/rndusr/privdata $HOME/git/privdata

cd $HOME/git/privdata
./handler.sh unarch

cd output
make
