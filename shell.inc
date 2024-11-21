
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

socksenableby socks5://172.24.85.187:7890

