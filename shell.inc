


#systemdu_tunnelprepare sshtunnel_usename <hostname>
#TODO test
systemdu_tunnelprepare() {
  appame=systemdu_tunnelprepare
  if [ "x$1" == "x" ]; then
    echo "$appame username hostname"
    return
  fi
  [ ! -f ~/.ssh/tunnel ] && ssh-keygen -f ~/.ssh/tunnel
  ssh -x root@$2 "useradd -m $1 && passwd $1"
  ssh-copy-id -i ~/.ssh/tunnel.pub $1@$2
  echo "better change $1@$2 to nologin"
}

systemdu_tunnellist() {
  ls /etc/systemd/system/sshtunnel_*
}
#TODO test
systemdu_tunnelcreate() {
  if [ "x$1" == "x" ]; then
    echo "$appame name -r"
    echo "$appame name -D 0.0.0.0:7890 sshtunnel@remotehost  #local socks5 server(out byssh server)"
    echo "$appame name -R 0.0.0.0:8022:127.0.0.1:22 sshtunnel@remotehost #remote 22 to local 22"
    echo "$appame name -L 0.0.0.0:80:127.0.0.1:80 sshtunnel@remotehost #local 80->remote:80"
    return
  fi
if [ "x$2" == "x-r" ]; then
  rm -f /etc/systemd/system/sshtunnel_${1}.service
fi

if [ "x$2" == "x-L" ] || [ "x$2" == "x-R" ] || [ "x$2" == "x-D" ]; then
cat <<EOF > /etc/systemd/system/sshtunnel_${1}.service
[Unit]
Description=Maintain Tunnel
After=network.target

[Service]
User=root
ExecStart=/usr/bin/ssh -i ~root/.ssh/tunnel -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -gnNT ${2} ${3} ${4} vmstat 5
RestartSec=15
Restart=always
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now sshtunnel_${1}.service
systemctl status sshtunnel_${1}.service
echo "sshtunnel_${1}"
fi

}


sethostname() { echo ${1} > /etc/hostname ; grep "^127.0.0.1 ${1}$" /etc/hosts || echo "127.0.0.1 ${1}" >> /etc/hosts ; hostname ${1}; }
prefixechodo() { echo "$@"; "$@"; }

cloudup_reload() {
  source /nfs.remote/_cloudup/shell.inc
}
socksenableby(){
    echo 'socksenableby socks5h://127.0.0.1:7890 #help'
    echo 'socksdisable #help'
    echo 'qenv_proxyXXXX #help'
  [ "x${1}" == "x" ] && {
    echo "usage: socksenableby socks5h://127.0.0.1:7890"
  } || {
    local proxyIp=$(echo ${1}|sed 's%://% %;s%:% %' | awk '{print $2}')
    local proxyPort=$(echo ${1}|sed 's%://% %;s%:% %' | awk '{print $3}')
    local pry_="_PROXY=${1}";
    prefixechodo export HTTP${pry_};
    prefixechodo export HTTPS${pry_};
    prefixechodo export FTP${pry_};
    prefixechodo export RSYNC${pry_};
    prefixechodo export ALL${pry_};
  }
}

socksdisable(){
  prefixechodo unset HTTP_PROXY
  prefixechodo unset HTTPS_PROXY
  prefixechodo unset FTP_PROXY
  prefixechodo unset RSYNC_PROXY
  prefixechodo unset ALL_PROXY
  prefixechodo export SBT_OPTS="$SBT_OPTS_ORIGIN"
}

which git && {

gitsu() {
  (set -x;
  git add . && git commit -m"info$*" && git pull &&  git push
  set +x;)
}
git config --global user.email "lrobot.qq@gmail.com"
git config --global user.name "lrobot"

}

#echo socksenableby socks5://172.24.85.187:7890
#echo socksenableby socks5h://172.24.85.187:7890


podman-composeu_restart() {
  podman-compose down
  podman-compose up -d
  podman-compose logs -f 
}
