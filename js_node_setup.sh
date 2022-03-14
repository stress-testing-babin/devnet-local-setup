# !/bin/sh

rm -rf ~/.nvm && rm -rf ~/.npm

curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y nodejs

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
. ~/.bashrc
. ~/.profile
npm update

npm install @dashevo/dashd-rpc
