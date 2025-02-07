
sethostname() { echo ${1} > /etc/hostname ; grep "^127.0.0.1 ${1}$" /etc/hosts || echo "127.0.0.1 ${1}" >> /etc/hosts ; hostname ${1}; }
reload() {
  source /opt/_cloudup/shell.inc
}
prefixechodo() { echo "$@"; "$@"; }
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

gitsu() {
  (set -x;
  git add . && git commit -m"info$*" && git pull &&  git push
  set +x;)
}
git config --global user.email "lrobot.qq@gmail.com"
git config --global user.name "lrobot"

#echo socksenableby socks5://172.24.85.187:7890
#echo socksenableby socks5h://172.24.85.187:7890


podman-composeu_restart() {
  podman-compose down
  podman-compose up -d
  podman-compose logs -f 
}
