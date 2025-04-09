#!/usr/bin/env bash
#set -x
mytime() {
  { time "$@" >/dev/null 2>&1 || echo "real 0m0.999s" ; } 2>&1  | grep real | tail -1 | sed -e 's/real[ \t] *//g'
}

time_curl() {
   mytime curl -v "$@"
}

test_set_mirror() {
  local usetime=$(time_curl $1)
  if [[ "$?" != "0" ]] ; then
    return
  fi
  if [[ "$usetime" < $fastest_time ]]; then
    fastest_time=$usetime
    fastest_url=$1
  fi
}

get_fast_debian_url() {
	local fastest_time="0m0.999s"
	local fastest_url="http://mirrors.tuna.tsinghua.edu.cn/"

	test_set_mirror http://deb.debian.org/
	test_set_mirror http://mirrors.aliyun.com/
	test_set_mirror http://mirrors.tencentyun.com/
	echo $fastest_url
}

has_qaptporxy() {
  curl --connect-timeout 3 -v http://qaptproxy.lan:3142 >/dev/null 2>&1
}

config_qaptporxy() {
cat <<EOF | tee /etc/apt/apt.conf.d/00proxy
//Debug::Acquire::http "true";
//Acquire::http { Proxy "http://qaptproxy.lan:3142"; };
Acquire::http::ProxyAutoDetect "/usr/local/bin/apt-proxy-checker";
EOF
mkdir -p /usr/local/bin
cat <<EOF | tee /usr/local/bin/apt-proxy-checker
#!/usr/bin/env bash
if curl --connect-timeout 3 -v http://qaptproxy.lan:3142 >/dev/null 2>&1 ; then
  echo -n http://qaptproxy.lan:3142
else
	echo -n DIRECT
fi
EOF
chmod a+x /usr/local/bin/apt-proxy-checker

}

is_debian() {
  source /etc/os-release 
  [ "x$ID" == "xdebian" ]
}

_boot_debian_changemirror_debian_trixie() {
  mirror_url_prefix=$1
cat <<EOF | tee /etc/apt/sources.list
deb ${mirror_url_prefix}debian/ testing main contrib non-free non-free-firmware
deb ${mirror_url_prefix}debian/ testing-updates main contrib non-free non-free-firmware
deb ${mirror_url_prefix}debian/ testing-backports main contrib non-free non-free-firmware
deb ${mirror_url_prefix}debian-security testing-security main contrib non-free non-free-firmware
EOF
}

_boot_debian_changemirror_debian_buster() {
  mirror_url_prefix=$1
cat <<EOF | tee /etc/apt/sources.list
deb ${mirror_url_prefix}debian/ buster main contrib non-free
deb ${mirror_url_prefix}debian buster-updates main contrib non-free
# deb ${mirror_url_prefix}debian/ buster-backports main contrib non-free
deb ${mirror_url_prefix}debian-security buster/updates main contrib non-free
EOF
}
_boot_debian_changemirror_debian_bullseye() {
  mirror_url_prefix=$1
cat <<EOF | tee /etc/apt/sources.list
deb ${mirror_url_prefix}debian/ bullseye main contrib non-free
deb ${mirror_url_prefix}debian/ bullseye-updates main contrib non-free
deb ${mirror_url_prefix}debian/ bullseye-backports main contrib non-free
deb ${mirror_url_prefix}debian-security bullseye-security main contrib non-free
EOF
}
_boot_debian_changemirror_debian_bookworm() {
  mirror_url_prefix=$1
cat <<EOF | tee /etc/apt/sources.list
deb ${mirror_url_prefix}debian/ bookworm main contrib non-free non-free-firmware
deb ${mirror_url_prefix}debian/ bookworm-updates main contrib non-free non-free-firmware
deb ${mirror_url_prefix}debian/ bookworm-backports main contrib non-free non-free-firmware
deb ${mirror_url_prefix}debian-security bookworm-security main contrib non-free non-free-firmware
EOF
}
# https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/

_boot_debian_changemirror_ubuntu_jammy() {
  mirror_url_prefix=$1
cat <<EOF | tee /etc/apt/sources.list
deb ${mirror_url_prefix}ubuntu/ jammy main restricted universe multiverse
deb ${mirror_url_prefix}ubuntu/ jammy-updates main restricted universe multiverse
deb ${mirror_url_prefix}ubuntu/ jammy-backports main restricted universe multiverse
deb ${mirror_url_prefix}ubuntu/ jammy-security main restricted universe multiverse
EOF
}

_boot_debian_changemirror_ubuntu_focal() {
  mirror_url_prefix=$1
cat <<EOF | tee /etc/apt/sources.list
deb ${mirror_url_prefix}ubuntu/ focal main restricted universe multiverse
deb ${mirror_url_prefix}ubuntu/ focal-updates main restricted universe multiverse
deb ${mirror_url_prefix}ubuntu/ focal-backports main restricted universe multiverse
deb ${mirror_url_prefix}ubuntu/ focal-security main restricted universe multiverse
EOF
}

boot_debian_changemirror() {
debian_url=$(get_fast_debian_url)
echo debian_url=$debian_url
rm -f /etc/apt/sources.list
rm -f /etc/apt/sources.list.d/debian_cn.list
source /etc/os-release
#VERSION_CODENAME, ID, from /etc/os-release
_boot_debian_changemirror_${ID}_${VERSION_CODENAME} $debian_url
}


do_cfg() {
is_debian && boot_debian_changemirror
has_qaptporxy  && config_qaptporxy
}

do_cfg

