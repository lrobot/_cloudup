#!/usr/bin/env bash
#from mypriv.sh
if test "x$BB_ASH_VERSION" != "x" ; then SCRIPT=$0; if test "x${SCRIPT}" = "x-ash" ; then SCRIPT=$1; fi; SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${SCRIPT}")" && pwd) ; fi
if test "x$ZSH_VERSION" != "x" ; then SCRIPT_DIR=${0:a:h} ; fi
if test "x$BASH_VERSION" != "x" ; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )" ; fi
if test "x$SHELL" = "x/bin/ash" ; then SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) ; fi

err_exit() {
  echo $*
  exit -1
}
echodo() { echo _run_cmd:"$@"; $@; }

cd $SCRIPT_DIR || err_exit


if [ "x$1" == "cn" ] ; then
update_mirror_cn() {
cat <<EOF > /etc/apt/sources.list
deb http://mirrors.tuna.tsinghua.edu.cn/debian bookworm main contrib
deb http://mirrors.tuna.tsinghua.edu.cn/debian bookworm-updates main contrib
deb http://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib
EOF
}
fi

# htpasswd need apache2-utils
# docker-compose
apt update
apt install -y apache2-utils curl podman python3-pip git dbus-broker vim dnsmasq bzip2 golang-github-containernetworking-plugin-dnsname podman-compose podman-docker
systemctl restart dbus-broker
systemctl stop dnsmasq
systemctl disable dnsmasq
# https://github.com/containers/podman-compose
if [ -f podman-compose.py ] ; then
  echodo cp podman-compose.py /usr/local/bin/podman-compose
else
if [ "x$cloudup_" != "x" ] ; then
  echodo curl -sSfL https://$cloudup_/podman-compose.py -o /tmp/podman-compose.py && echodo cp -a /tmp/podman-compose.py /usr/local/bin/podman-compose
else
echo export cloudup_url=xxxxxx 
echo cp podman-compose.py /usr/local/bin/podman-compose
echo chmod a+x /usr/local/bin/podman-compose
fi
fi

chmod a+x /usr/local/bin/podman-compose
grep docker /etc/containers/registries.conf || {
 echo "add docker.io for docker search"
 echo 'unqualified-search-registries = ["docker.io"]' >> /etc/containers/registries.conf
}

# https://github.com/containers/dnsname/blob/main/README_PODMAN.md
# https://stackoverflow.com/questions/73941967/podman-containers-cant-see-eachother-via-host-name
#cp dnsname /usr/lib/cni/
#mkdir -p /etc/apparmor.d/local/
#cp usr.sbin.dnsmasq /etc/apparmor.d/local/
#which apparmor_parser  && apparmor_parser -r /etc/apparmor.d/local/usr.sbin.dnsmasq
