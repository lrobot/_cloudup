Osname() { uname -s; }
osname() { uname -s | tr '[:upper:]' '[:lower:]'; }
is_darwin() { [[ "x$(uname -s)" == "xDarwin" ]]; }
is_linux() { [[ "x$(uname -s)" == "xLinux" ]]; }
is_mingw() { [[ "x$(uname -s)" == "xMINGW64_NT" ]]; }
shellname() { is_linux && basename $(readlink /proc/$$/exe) || { is_darwin && basename $(ps -p $$ -ocomm=|sed 's/-//g'); };}
is_bash() { [[ "x$(shellname)" == "xbash" ]]; }
is_zsh() { [[ "x$(shellname)" == "xzsh" ]]; }
is_ash() { [[ "x$(shellname)" == "xash" ]] || [[ "x$(shellname)" == "xbusybox" ]]; }
hasbin() { which ${1} &> /dev/null;}


is_bash && {
set +o posix #bash need this for <() work
trysource_completion() {
  [[ -z $BASH_COMPLETION_VERSINFO ]] && return
  local bin=$1; hasbin $bin && source <($@);
}
}
is_zsh && {
setopt NO_NOMATCH
trysource_completion() {
  ! hasbin complete && return
  local bin=$1; hasbin $bin && source <($@);
}
}
is_ash && {
trysource_completion() { :; }
}

hasbin fzf && {
is_bash && source <(fzf --bash)
is_zsh && source <(fzf --zsh)
}

if [ "x${SHELL}" == "x" ]; then
  alias reload='exec sh -l'
else
  alias reload="exec ${SHELL} -l"
fi



srvdo() {
  local srv=$1
  local oper=$2
  if [ -x /etc/init.d/${srv} ] ; then
    /etc/init.d/${srv} ${oper}
  else
    hasbin systemctl && systemctl ${oper} ${srv}
    hasbin rc-service &&  rc-service -i ${srv} ${oper}
  fi
}
srvenable() {
 hasbin rc-update && rc-update add $1 default
 hasbin systemctl && systemctl enable $1
}


echodo() { echo _rshell:"$@"; $@; }

# https://github.com/VSCodium/vscodium/blob/master/docs/index.md#howto-switch-marketplace
#this still not work
#now need modify /usr/lib/code-oss/resources/app/product.json 
#  "extensionsGallery": {
#    "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
#    "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
#    "itemUrl": "https://marketplace.visualstudio.com/items",
#    "_serviceUrl": "https://open-vsx.org/vscode/gallery",
#    "_itemUrl": "https://open-vsx.org/vscode/item"
#  },
#export VSCODE_GALLERY_SERVICE_URL=https://marketplace.visualstudio.com/_apis/public/gallery
#export VSCODE_GALLERY_ITEM_URL=https://marketplace.visualstudio.com/items

export GO111MODULE=on
export GOPROXY=https://goproxy.cn
export GOPROXY=https://goproxy.io,direct

when_login_echo() {
echo $(hostname) ==============================
ip addr | grep 'inet ' 

}
when_login_echo
export PATH=$(echo /root/istio-*/bin):$PATH
export cloudup_=cloudup.danfestar.cn; 
clouduprun() { wget -O- http://${cloudup_}/${1} | sh; }


[ -e /run/containerd/containerd.sock ] && export CONTAINER_RUNTIME_ENDPOINT=unix:///run/containerd/containerd.sock
[ -f /etc/kubernetes/admin.conf ] && export KUBECONFIG=/etc/kubernetes/admin.conf
hasbin etcdctl && [ -f /etc/kubernetes/pki/etcd/server.key ] && {
export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=127.0.0.1:2379
export ETCDCTL_DIAL_TIMEOUT=3s
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key
}


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




ipu_show() {
ip route show table all
ip rule
ip link
ip tuntap
}

gitu_configusername() {
	if [ "x$2" == "x" ] ; then
		echo "help: $0 <user.name> <user.email>"
	else
		echodo git config --global user.name $1
		echodo git config --global user.email $2
	fi
}



hasbin crictl && {
is_bash && trysource_completion crictl completion bash
is_zsh && trysource_completion crictl completion zsh
}

hasbin kubeadm && {

#is_bash && trysource_completion kubeadm completion bash
#is_zsh && trysource_completion kubeadm completion zsh

k8s_kubeconfig_by_kubeadm() {
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

k8s_clearup() {
srvdo kubelet stop
kubeadm reset -f
crictl rmp -af
crictl rm -af
#crictl rmi -aq
rm -rf /etc/kubernetes
rm -rf /var/lib/etcd/
rm -rf /var/lib/kubelet/*
rm -rf /etc/cni/net.d/
rm -rf /var/log/kubelet/*
mkdir -p /var/log/kubelet
rm -rf ~/.kube/
iptables --flush
iptables -tnat --flush
ip link delete cni0
ip link delete flannel.1

}


k8s_init_controlnode() {
 if [ $# -lt 2 ] ; then
   echo "k8s_init_controlnode controlEndpoint nodeName"
   echo "k8s + cluater_name + c + e, c:ctrl e:entry"
   echo "k8s_init_controlnode k8sdce k8sdc1"
   echo "k8s_init_controlnode k8sdce k8sdc2"
   echo "k8s_init_controlnode k8sdce k8sdc3"
   return
 fi
controlEndpoint=$1
nodeName=$2
nodeNamePrefix=${nodeName%?}
nodeNameSuffix=${nodeName: -1}
if [ "x$nodeNameSuffix" = "x1" ]; then
keepaliveState=MASTER
else
keepaliveState=BACKUP
fi
ctrlEpIp=$(getent hosts ${controlEndpoint}|awk '{print $1}')
if [ "x$ctrlEpIp" = "x" ]; then
  echo "err get ip of $controlEndpoint"
	return
fi
echo ip is: $ctrlEpIp
 
apk add haproxy keepalived
echo $nodeName > /etc/hostname
sed -i "s/127\.0\.0\.1.*$/127.0.0.1 ${nodeName}.lan ${nodeName} localhost.localdomain localhost/g" /etc/hosts
curl -sSfL https://${cloudup_}/haproxy.cfg | sed "s/k8sc/${nodeNamePrefix}/g" > /etc/haproxy/haproxy.cfg
srvenable haproxy
srvdo haproxy restart
mkdir -p /etc/keepalived
(cd /etc/keepalived && {
 curl -sSfL http://${cloudup_}/keepalived.conf |
        sed -e "s/192.168.1.XX/${ctrlEpIp}/g" |
        sed -e "s/priority 10X/priority 10${nodeNameSuffix}/g" |
        sed -e "s/state MASTER/state $keepaliveState/g" > /etc/keepalived/keepalived.conf
 curl -sSfLO http://${cloudup_}/keepalived.check.sh
 chmod a+x keepalived.check.sh
})
srvenable keepalived
srvdo keepalived restart
kubeadm config images pull --image-repository registry.aliyuncs.com/google_containers
mkdir -p /var/log/kubelet
if [ "x$nodeNameSuffix" = "x1" ]; then
echodo kubeadm init --v=5 --upload-certs --image-repository registry.aliyuncs.com/google_containers --control-plane-endpoint=${controlEndpoint}:16443 --pod-network-cidr=10.244.0.0/16 | tee ~/join.txt
export KUBECONFIG=/etc/kubernetes/admin.conf
echodo kubectl apply -f  https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
else
echo need run: kubeadm join xxx
fi
}

kubeadmu_dumpinfo() {
  echo "--discovery-token-ca-cert-hash sha256:$(certu_certsha256 /etc/kubernetes/pki/ca.crt)"
}


kubeadmu_showjoin() {
  kubeadm token create --print-join-command
  #echo "kubeadm join $(kubectlutil_getclusterserver) --token $(kubeadm token create) --discovery-token-ca-cert-hash sha256:$(certu_certsha256 /etc/kubernetes/pki/ca.crt)"
}

kubeadmu_showjoinctrlpane() {
  CERT_ENCRYPT_KEY_IN_kubeadm_certs_Secret=$(kubeadm certs certificate-key)
  echo certificate key :${CERT_ENCRYPT_KEY_IN_kubeadm_certs_Secret}
  kubeadm init phase upload-certs --upload-certs --certificate-key ${CERT_ENCRYPT_KEY_IN_kubeadm_certs_Secret}
  echo can: "kubeadmutilcheck && $(kubeadm token create --print-join-command) --v=5 --control-plane --certificate-key ${CERT_ENCRYPT_KEY_IN_kubeadm_certs_Secret}"
}

kubeadmu_reset() {
  set -x
  kubeadm reset phase remove-etcd-member
  kubeadm reset -f
  srvdo kubelet stop
  nerdctl_clear_k8s
  pkill -f 'namespace k8s.io'
  df -h |grep kubelet| sed 's@^.*/var/lib/kubelet@/var/lib/kubelet@' | xargs -n1 umount || true
  hasbin ipvsadm && ipvsadm --clear
  ip link delete cni0
  ip link delete flannel.1
  rm -rf /etc/kubernetes/
  ls /etc/cni/net.d/* | grep -v 10-containerd-net.conflist | xargs -n1 rm -f
  rm -rf /var/lib/{cni,calico,etcd,flannel}
  rm -rf /var/run/{cni,calico,etcd,flannel}
  rm -rf ~/.kube
  set +x
}

}

