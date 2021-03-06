#!/bin/bash
: '
	@name   ReconPi install.sh
	@author Martijn B <Twitter: @x1m_martijn>
	@link   https://github.com/x1mdev/ReconPi
'

: 'Set the main variables'
YELLOW="\033[133m"
GREEN="\033[032m"
RESET="\033[0m"
VERSION="2.0"

: 'Display the logo'
displayLogo() {
    clear
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

: 'Basic requirements'
basicRequirements() {
    echo -e "[$GREEN+$RESET] This script will install the required dependencies to run recon.sh, please stand by.."
    echo -e "[$GREEN+$RESET] It will take a while, go grab a cup of coffee :)"
    cd "$HOME" || return
    sleep 1
    echo -e "[$GREEN+$RESET] Getting the basics.."
    export LANGUAGE=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    sudo apt-get update -y
    sudo apt-get install git -y
    git clone https://github.com/x1mdev/ReconPi.git
    sudo apt-get install -y --reinstall build-essential
    sudo apt install -y python3-pip
    sudo apt-get install -y dnsutils
    sudo apt install -y lua5.1 alsa-utils libpq5
    sudo apt-get autoremove -y
    sudo apt clean
    echo -e "[$GREEN+$RESET] Stopping Docker service.."
    sudo systemctl disable docker.service
    sudo systemctl disable docker.socket
    echo -e "[$GREEN+$RESET] Creating directories.."
    mkdir -p "$HOME"/tools
    mkdir -p "$HOME"/go
    mkdir -p "$HOME"/go/src
    mkdir -p "$HOME"/go/bin
    mkdir -p "$HOME"/go/pkg
    sudo chmod u+w .
    echo -e "[$GREEN+$RESET] Done."
}

: 'Golang initials'
golangInstall() {
    echo -e "[$GREEN+$RESET] Installing and setting up Go.."
    if [[ $(go version | grep -o '1.13') == 1.13 ]]; then
        echo -e "[$GREEN+$RESET] Go is already installed, skipping installation"
    else
        cd "$HOME"/tools || return
        git clone https://github.com/udhos/update-golang
        cd "$HOME"/tools/update-golang || return
        sudo bash update-golang.sh
        echo -e "[$GREEN+$RESET] Done."
    fi
    echo -e "[$GREEN+$RESET] Adding recon alias & Golang to "$HOME"/.bashrc.."
    sleep 1
    configfile="$HOME"/.bashrc
    if grep -q /go/bin/ "$configfile"; then
        echo -e "[$GREEN+$RESET] .bashrc contains the correct lines."
    else
        echo export GOPATH='$HOME'/go >>"$HOME"/.bashrc
        echo export GOROOT=/usr/local/go >>"$HOME"/.bashrc
        echo export PATH='$PATH:$HOME'/go/bin/ >>"$HOME"/.bashrc
        echo export PATH='$PATH:$GOROOT'/bin >>"$HOME"/.bashrc
        echo export PATH='$PATH:$HOME'/.local/bin >>"$HOME"/.bashrc
        echo "alias recon=$HOME/ReconPi/recon.sh" >>"$HOME"/.bashrc
        echo export LANGUAGE=en_US.UTF-8 >>"$HOME"/.bashrc
        echo export LANG=en_US.UTF-8 >>"$HOME"/.bashrc
        echo export LC_ALL=en_US.UTF-8 >>"$HOME"/.bashrc
    fi
    bash /etc/profile.d/golang_path.sh
    source "$HOME"/.bashrc
    cd "$HOME" || return
    echo -e "[$GREEN+$RESET] Golang has been configured."
}

: 'Golang tools'
golangTools() {
    echo -e "[$GREEN+$RESET] Installing subfinder.."
    if [ -e "$HOME"/go/bin/subfinder ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        go get -u github.com/projectdiscovery/subfinder/cmd/subfinder
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing subjack.."
    if [ -e "$HOME"/go/bin/subjack ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        go get github.com/haccer/subjack
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing aquatone.."
    if [ -e "$HOME"/go/bin/aquatone ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        go get -u github.com/michenriksen/aquatone
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing httprobe.."
    if [ -e "$HOME"/go/bin/httprobe ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        go get -u github.com/tomnomnom/httprobe
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing assetfinder.."
    if [ -e "$HOME"/go/bin/assetfinder ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        go get -u github.com/tomnomnom/assetfinder
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing meg.."
    if [ -e "$HOME"/go/bin/meg ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        go get -u github.com/tomnomnom/meg
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing tojson.."
    if [ -e "$HOME"/go/bin/tojson ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        go get -u github.com/tomnomnom/hacks/tojson
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing gobuster.."
    if [ -e "$HOME"/go/bin/gobuster ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        go get github.com/OJ/gobuster
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing Amass.."
    if [ -e "$HOME"/go/bin/amass ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        go get github.com/OWASP/Amass
        export GO111MODULE=on
        cd "$HOME"/go/src/github.com/OWASP/Amass || return
        go install ./...
        export GO111MODULE=off
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing getJS.."
    if [ -e "$HOME"/go/bin/getJS ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        go get -u github.com/003random/getJS
        echo -e "[$GREEN+$RESET] Done."
    fi

}

: 'Additional tools'
additionalTools() {
    echo -e "[$GREEN+$RESET] Installing massdns.."
    if [ -e /usr/local/bin/massdns ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        cd "$HOME"/tools/ || return
        git clone https://github.com/blechschmidt/massdns.git
        cd "$HOME"/tools/massdns || return
        echo -e "[$GREEN+$RESET] Running make command for massdns.."
        make -j
        sudo cp "$HOME"/tools/massdns/bin/massdns /usr/local/bin/
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing jq.."
    sudo apt install -y jq
    echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing Chromium browser.."
    sudo apt install -y chromium-browser
    echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing masscan.."
    if [ -e /usr/local/bin/masscan ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        cd "$HOME"/tools/ || return
        git clone https://github.com/robertdavidgraham/masscan
        cd "$HOME"/tools/masscan || return
        make -j
        sudo cp bin/masscan /usr/local/bin/masscan
        sudo apt install libpcap-dev -y
        cd "$HOME"/tools/ || return
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing CORScanner.."
    if [ -e "$HOME"/tools/CORScanner/cors_scan.py ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        cd "$HOME"/tools/ || return
        git clone https://github.com/chenjj/CORScanner.git
        cd "$HOME"/tools/CORScanner || return
        sudo pip3 install -r requirements.txt
        pip3 install future
        cd "$HOME"/tools/ || return
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing sublert.."
    if [ -e "$HOME"/tools/sublert/sublert.py ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        git clone https://github.com/yassineaboukir/sublert.git
        cd "$HOME"/tools/sublert || return
        sudo apt-get install -y libpq-dev dnspython psycopg2 tld termcolor
        pip3 install -r requirements.txt --user
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing LinkFinder.."
    # needs check
    if [ -e "$HOME"/tools/LinkFinder/linkfinder.py ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        cd "$HOME"/tools/ || return
        git clone https://github.com/GerbenJavado/LinkFinder.git
        cd "$HOME"/tools/LinkFinder || return
        pip3 install -r requirements.txt --user
        sudo python3 setup.py install
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing bass.."
    # needs check
    if [ -e "$HOME"/tools/bass/bass.py ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        cd "$HOME"/tools/ || return
        git clone https://github.com/Abss0x7tbh/bass.git
        cd "$HOME"/tools/bass || return
        sudo pip3 install tldextract
        pip3 install -r requirements.txt --user
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing interlace.."
    if [ -e /usr/local/bin/interlace ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        cd "$HOME"/tools/ || return
        git clone https://github.com/codingo/Interlace.git
        cd "$HOME"/tools/Interlace || return
        sudo python3 setup.py install
        echo -e "[$GREEN+$RESET] Done."
    fi

    echo -e "[$GREEN+$RESET] Installing nmap.."
    if [ -e /usr/bin/nmap ]; then
        echo -e "[$GREEN+$RESET] Already installed."
    else
        sudo apt-get install -y nmap
        echo -e "[$GREEN+$RESET] Done."
    fi

}

: 'Dashboard setup'
setupDashboard() {
    echo -e "[$GREEN+$RESET] Installing Nginx.."
    sudo apt-get install -y nginx
    sudo nginx -t
    echo -e "[$GREEN+$RESET] Done."
    cd /var/www/html/ || return
    sudo chmod -R 755 .
    # setup index.html??
}

: 'Finalize'
finalizeSetup() {
    echo -e "[$GREEN+$RESET] Finishing up.."
    displayLogo
    cd "$HOME" || return
    echo "reconpi" > hostname
    sudo mv hostname /etc/hostname
    touch motd
    displayLogo >>motd
    sudo mv "$HOME"/motd /etc/motd
    cd "$HOME" || return
    echo -e "[$GREEN+$RESET] Installation script finished! System will reboot to finalize installation."
    sleep 1
    sudo reboot
}

: 'Execute the main functions'
displayLogo
basicRequirements
golangInstall
golangTools
additionalTools
setupDashboard
finalizeSetup
