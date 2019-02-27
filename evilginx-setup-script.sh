#!/bin/bash

usage() {
    cat <<EOF
${0##*/}
Usage: ${0##*/} [install|start] [option(s)]

    install     update & install EvilGinx2
    start       start EvilGinx2

  Options:

    -d          Phishing Domain (optional)
    -ip         Public IP Address (optional)
    -h          Help
EOF
exit 0
}


install()
{

    printf '\n============================================================\n'
    printf '[+] Setting up environment\n'
    printf '============================================================\n\n'
    gopath_exp='export GOPATH="$HOME/.go"'
    path_exp='export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"'
    sed -i '/export GOPATH=.*/c\' ~/.profile
    sed -i '/export PATH=.*GOPATH.*/c\' ~/.profile
    #sed -i "/export GOPATH=.*/c$gopath_exp" ~/.profile
    echo $gopath_exp | tee -a "$HOME/.profile"
    grep -q -F "$path_exp" "$HOME/.profile" || echo $path_exp | tee -a "$HOME/.profile"
    . "$HOME/.profile"

    printf '\n============================================================\n'
    printf '[+] Installing dependencies\n'
    printf '============================================================\n\n'
    sudo apt-get -y install golang git make

    printf '\n============================================================\n'
    printf '[+] Installing Evilginx2\n'
    printf '============================================================\n\n'
    go get -v -a -u github.com/kgretzky/evilginx2
    # cd "$GOPATH/src/github.com/kgretzky/evilginx2"
    # make
    # sudo make install

}

start()
{

    if [ -z "$TMUX" ]
    then
        printf "\n [+] Don't forget to start a TMUX session!!\n\n"
        sleep 7
    fi

    . "$HOME/.profile"

    rc_file="/tmp/evilginx_rc"

    cat <<EOF > "$rc_file"
config ip $ip
config domain $domain
config redirect_url https://www.foxnews.com/
config
EOF

    sudo "$GOPATH/bin/evilginx2" \
        -p "$GOPATH/src/github.com/blacklanternsecurity/evilginx2/phishlets"
        # -rc "$rc_file"

}




ip=$(curl ifconfig.me 2>/dev/null)

while :; do
    case $1 in
        -d|-D|--domain)
            shift
            domain="$1"
            break
            ;;
        -ip|-IP|--ip|--IP)
            shift
            ip="$1"
            break
            ;;
        install)
            install_evilginx="true"
            break
            ;;
        start)
            start_evilginx="true"
            break
            ;;
        -h|-H|--help)
            usage
            break
            ;;
        *)
            break
    esac
    shift
done

if [ -n "$install_evilginx" ]
then
    executed="true"
    install
fi
if [ -n "$start_evilginx" ]
then
    executed="true"
    start
fi

if [ -z "$executed" ]
then
    printf '\n[+] Please specify "install" or "start"\n\n'
fi
