if [ "x${SHELL}" == "x" ]; then
  alias reload='exec sh -l'
else
  alias reload="exec ${SHELL} -l"
fi


when_login_echo() {
echo $(hostname) ==============================
ip addr | grep 'inet ' 

}
when_login_echo
export PATH=$(echo /root/istio-*/bin):$PATH
export cloudup_=cloudup.danfestar.cn; 
clouduprun() { wget -O- http://cloudup.danfestar.cn/${1} | sh; }


[ -e /run/containerd/containerd.sock ] && export CONTAINER_RUNTIME_ENDPOINT=unix:///run/containerd/containerd.sock
[ -f /etc/kubernetes/admin.conf ] && export KUBECONFIG=/etc/kubernetes/admin.conf


proxyenableby(){ 
    echo 'proxyenableby socks5h://127.0.0.1:7890 #help'
    echo 'proxydisable #help'
    echo 'qenv_proxyXXXX #help'
  [ "x${1}" == "x" ] && {
    echo "usage: proxyenableby socks5h://127.0.0.1:7890"
  } || {
    local proxyIp=$(echo ${1}|sed 's%://% %;s%:% %' | awk '{print $2}')
    local proxyPort=$(echo ${1}|sed 's%://% %;s%:% %' | awk '{print $3}')
    local PRY_="_PROXY=${1}";
    local pry_="_proxy=${1}";
    prefixechodo export http${pry_};
    prefixechodo export https${pry_};
    prefixechodo export ftp${pry_};
    prefixechodo export rsync${pry_};
    prefixechodo export all${pry_};

    prefixechodo export HTTP${PRY_};
    prefixechodo export HTTPS${PRY_};
    prefixechodo export FTP${PRY_};
    prefixechodo export RSYNC${PRY_};
    prefixechodo export ALL${PRY_};
    prefixechodo export JAVA_SOCKS_OPTS="-DsocksProxyHost=${proxyIp} -DsocksProxyPort=${proxyPort}"
    prefixechodo export SBT_OPTS="$SBT_OPTS_ORIGIN ${JAVA_SOCKS_OPTS}"
    #[https://gist.github.com/bynil/2126e374db8495fe33de2cbc543149ae](Use git over socks5 proxy)
    prefixechodo export GIT_SSH_COMMAND='ssh -o ProxyCommand="nc -X 5 -x '${proxyIp}:${proxyPort}' %h %p"'
  }
}
proxyenablebysocks5(){ echo "proxyenablebysocks5 127.0.0.1:7890 #help" ;  proxyenableby socks5://$1; }
proxyenablebysocks5h(){ echo "proxyenablebysocks5h 127.0.0.1:7890 #help" ;  proxyenableby socks5h://$1; }
proxyenablebyhttp(){ echo "proxyenablebyhttp 127.0.0.1:7890 #help" ;  proxyenableby http://$1; }
proxyenablebyhttps(){ echo "proxyenablebyhttps 127.0.0.1:7890 #help" ;  proxyenableby https://$1; }

proxydisable(){ 
  prefixechodo unset http_proxy
  prefixechodo unset https_proxy
  prefixechodo unset ftp_proxy
  prefixechodo unset rsync_proxy
  prefixechodo unset all_proxy
  prefixechodo unset HTTP_PROXY
  prefixechodo unset HTTPS_PROXY
  prefixechodo unset FTP_PROXY
  prefixechodo unset RSYNC_PROXY
  prefixechodo unset ALL_PROXY
  prefixechodo unset GIT_SSH_COMMAND
  prefixechodo export SBT_OPTS="$SBT_OPTS_ORIGIN"
}

proxystandby() {
  _PROXY_STANDBY=$1
}

proxyondo() {(
  proxyenableby ${_PROXY_STANDBY}
  "$@"
)}

proxyoffdo() {(
  proxydisable
  "$@"
)}



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

which git > /dev/null 2>&1 && {

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


_tailscale_up() {
_local_domain_name=$1
[ "x$_local_domain_name" == "x" ] && _local_domain_name=$env_domain_name_www
[ "x$_local_domain_name" == "x" ] && _local_domain_name=www.$env_domain_name
[ "x$_local_domain_name" == "x" ] && {
  echo "no domain name"
  exit
}
echo tailscale down
echo 'net.ipv4.ip_forward = 1' | tee /etc/sysctl.d/ipforwarding.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/ipforwarding.conf
sysctl -p /etc/sysctl.d/ipforwarding.conf
echo tailscale up --accept-routes=true --accept-dns=false --reset --login-server=https://$_local_domain_name ${_tailscale_extra_opt}
}

tailscale_up() {
	_tailscale_extra_opt=
	_tailscale_up "$@"
}
tailscale_up_home() {
	_tailscale_extra_opt=--advertise-routes=192.168.1.0/24
	_tailscale_up "$@"
}


k8s_kubeconfig_by_kubeadmin() {
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

k8s_clearup() {

/etc/init.d/kubelet stop
crictl pods -q | xargs -n1 crictl stopp
crictl pods -q | xargs -n1 crictl rmp
rm -rf /etc/kubernetes
rm -rf /var/lib/etcd
kubeadm reset

}

k8s_init_nodemaster() {

[ -f ~/k8s_init_cfg.yml ] || kubeadm config print init-defaults > ~/k8s_init_cfg.yml
echo find 1.2.3.4 to replace
vi ~/k8s_init_cfg.yml
kubeadm --v=5 init --config ~/k8s_init_cfg.yml
#kubeadm --v=5 init --config ~/k8s_init_cfg.yml --pod-network-cidr=10.244.0.0/16 --node-name=$(hostname)

}
