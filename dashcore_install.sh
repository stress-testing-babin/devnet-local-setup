# !/bin/sh

sudo apt install wget
sudo apt install tar

mkdir ./tmp && cd ./tmp
wget https://github.com/dashpay/dash/releases/download/v0.17.0.3/dashcore-0.17.0.3-x86_64-linux-gnu.tar.gz

tar xfv dashcore-0.17.0.3-x86_64-linux-gnu.tar.gz
sudo cp -t /usr/local/bin dashcore-*/bin/*

cd ..

rm -rf ./tmp

rm -rf ~/.dashcore && mkdir ~/.dashcore
cp -t ~/.dashcore ./dash.conf
