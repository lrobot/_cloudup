#!/bin/sh
#from mypriv.sh
if test "x$BB_ASH_VERSION" != "x" ; then SCRIPT=$0; if test "x${SCRIPT}" = "x-ash" ; then SCRIPT=$1; fi; SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${SCRIPT}")" && pwd) ; fi
if test "x$ZSH_VERSION" != "x" ; then SCRIPT_DIR=${0:a:h} ; fi
if test "x$BASH_VERSION" != "x" ; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )" ; fi
if test "x$SHELL" = "x/bin/ash" ; then SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) ; fi
set -x

err_exit() {
  echo $*
  exit -1
}
echodo() { echo _run_cmd:"$@"; $@; }

cd $SCRIPT_DIR || err_exit

_is_distro() {
  cat /proc/version | grep -iq "$1"
}

is_alpine() { command -v apk >/dev/null 2>&1 && { apk --version | grep -q apk-tools > /dev/null 2>&1; }; }

is_debian() {
  _is_distro "Debian"
}

is_ubuntu() {
  _is_distro "Ubuntu"
}

update_mirror_debian_cn() {
cat <<EOF > /etc/apt/sources.list
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ testing main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ testing-updates main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ testing-backports main contrib non-free non-free-firmware
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security testing-security main contrib non-free non-free-firmware
EOF
}
update_mirror_ubuntu_cn() {
cat <<EOF > /etc/apt/sources.list.d/ubuntu.sources
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
}

if [ "x$1" = "xcn" ] ; then
if [ ! -f /etc/apt/cfg.done ]; then
is_debian && echodo update_mirror_debian_cn
is_ubuntu && echodo update_mirror_ubuntu_cn
fi
fi

install_new_podman_compose() {

[ "x${cloudup_}" = "x" ] &&  cloudup_=$(wget -q --no-check-certificate -O- http://gitee.com/lrobot/dev_info/raw/master/cloudup_url.txt)
wget -q --no-check-certificate -O /usr/local/bin/podman-compose http://${cloudup_}/podman-compose.py
chmod +x /usr/local/bin/podman-compose
}


podman_install_debian() {
# htpasswd need apache2-utils
# docker-compose
apt update
apt install -y apache2-utils curl podman python3-pip git dbus-broker vim dnsmasq bzip2 golang-github-containernetworking-plugin-dnsname podman-compose podman-docker
sysctl vm.mmap_min_addr=0
# https://docs.daocloud.io/en/amamba/user-guide/pipeline/podman#install-qemu-binary-files
# https://www.kernel.org/doc/html/latest/admin-guide/binfmt-misc.html
# https://wiki.debian.org/QemuUserEmulation
apt install -y binfmt-support qemu-user-static
update-binfmts --display
systemctl restart dbus-broker
systemctl stop dnsmasq
systemctl disable dnsmasq

install_new_podman_compose

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
}
podman_install_alpine() {
apk add podman podman-compose dnsmasq
rc-update add cgroups
rc-update add podman
rc-service cgroups start
rc-service podman start
install_new_podman_compose
}

is_debian && echodo podman_install_debian
is_alpine && echodo podman_install_alpine

