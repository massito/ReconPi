#!/bin/bash
: '
	@name   ReconPi install.sh
	@author Martijn Baalman <@x1m_martijn>
	@link   https://github.com/x1mdev/ReconPi
'


: 'Set the main variables'
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RESET="\033[0m"
VERSION="0.2.0"


: 'Display the logo'
displayLogo()
{
	echo -e "
__________                          __________.__
\______   \ ____   ____  ____   ____\______   \__|
 |       _// __ \_/ ___\/  _ \ /    \|     ___/  |
 |    |   \  ___/\  \__(  <_> )   |  \    |   |  |
 |____|_  /\___  >\___  >____/|___|  /____|   |__|
        \/     \/     \/           \/
                          v$VERSION - by $YELLOW@x1m_martijn$RESET
	"
}

displayLogo;

echo -e "[$GREEN+$RESET] This is the first script that will install the required dependencies to run recon.sh, please stand by..";
echo -e "[$GREEN+$RESET] It will take a while, go grab a cup of coffee :)";
sleep 1;
echo -e "[$GREEN+$RESET] Getting the basics..";
sudo apt-get install git -y;
sudo apt-get update -y;
sudo apt-get upgrade -y; #turned off for dev, needs to run at initial setup though. security yo

echo -e "[$GREEN+$RESET] Installing and setting up Go..";
cd "$HOME" || return;
wget https://dl.google.com/go/go1.10.3.linux-armv6l.tar.gz; # takes a long time but does get a LOT of good dependencies
sudo tar -xvf go1.10.3.linux-armv6l.tar.gz;
echo -e "[$GREEN+$RESET] Creating directories..";
mv go go1.10;
mkdir -p tools;
mkdir -p go;
# clone ReconPi repo because stretch lite lacks git by default -.-
git clone https://github.com/x1mdev/ReconPi.git;
echo -e "[$GREEN+$RESET] Done.";
sudo chmod u+w .;
# set export crap right
echo -e 'export GOPATH=$HOME/go' >> $HOME/.bashrc;
echo -e 'export GOROOT=$HOME/go1.10' >> $HOME/.bashrc;
echo -e 'export PATH=$PATH:$GOPATH' >> $HOME/.bashrc;
echo -e 'export PATH=$PATH:$GOROOT/bin' >> $HOME/.bashrc;
source $HOME/.bashrc;
go version;
go env;
cd $HOME/tools/;

echo -e "[$GREEN+$RESET] Installing Node & NPM..";
sudo apt-get install -y npm;
sudo apt-get install -y nodejs-legacy;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing Subfinder..";
go get github.com/subfinder/subfinder;
sudo cp $HOME/go/bin/subfinder /usr/local/bin/;
echo -e "[$GREEN+$RESET] Done.";

# skipping docker as massdns make command runs perfectly

echo -e "[$GREEN+$RESET] Installing massdns..";
cd $HOME/tools/;
git clone https://github.com/blechschmidt/massdns.git;
cd massdns;
make;
sudo cp $HOME/tools/massdns/bin/massdns /usr/local/bin/;
# werkt met make command, sneller dan docker
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing teh_s3_bucketeers..";
git clone https://github.com/tomdev/teh_s3_bucketeers.git;
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing virtual host discovery..";
git clone https://github.com/jobertabma/virtual-host-discovery.git;
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing nmap..";
sudo apt-get install -y nmap;
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

# NEEDS TO BE SORTED OUT WITH NEW GO WEBAPP

echo -e "[$GREEN+$RESET] Installing Nginx.."; #needs new dashboard
sudo apt-get install -y nginx;
echo -e "[$GREEN+$RESET] Removing default Nginx setup..";
#sudo rm /etc/nginx/sites-available/default;
#sudo rm /etc/nginx/sites-enabled/default;
echo -e "[$GREEN+$RESET] Configuring ReconPi Nginx setup..";
#sudo cp $HOME/ReconPi/dashboard-nginx /etc/nginx/sites-available/;
#sudo ln -s /etc/nginx/sites-available/dashboard-nginx /etc/nginx/sites-enabled/dashboard-nginx;
#sudo service nginx restart;
sudo nginx -t;
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Cleaning up.";
displayLogo;
cd $HOME;
rm go1.10.3.linux-armv6l.tar.gz;
rm install.sh; 
sleep 2;
echo -e "[$GREEN+$RESET] Initial script finished! System will reboot to finalize install.";
sleep 1;
sudo reboot;
# Pi needs  a reboot because of all the changes