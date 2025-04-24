#!/bin/sh

fstab_add() {
  local mount_host=$1
  local mount_path=$2
  grep -q ${mount_path} /etc/exports 2>/dev/null && {
    echo "${mount_path} this host export ${mount_path}, not do fstab_add"
    return 0;
  }
  which apk >/dev/null 2>&1 && {
    apk add nfs-utils
    rc-update add netmount default #this enable auto netmount in fstab
  }
  which apt-get >/dev/null 2>&1 && ( apt-get update; apt-get install -y nfs-common )
  mkdir -p /${mount_path}
  grep -q ${mount_path} /etc/fstab && {
    echo "${mount_path} already in /etc/fstab"
    return 0
  }
  if which mount.nfs4 >/dev/null 2>&1 ; then
    mount_fstype=nfs4
  else
    mount_fstype=nfs
  fi
  echo ${mount_host}:/${mount_path} /${mount_path} ${mount_fstype}  defaults,ro,nofail 0 0 >> /etc/fstab
  mount /${mount_path}
}


ping -c 1 qdisk.lan >/dev/null 2>&1 && {
  fstab_add qdisk.lan nfs.local
}

[ "x${cloudup_}" = "x" ] &&  cloudup_=$(wget -q --no-check-certificate -O- http://gitee.com/lrobot/dev_info/raw/master/cloudup_url.txt)
ping -c 1 ${cloudup_} >/dev/null 2>&1 && {
  fstab_add ${cloudup_} nfs.remote
  which systemctl >/dev/null 2>&1 && systemctl daemon-reload

mkdir -p /etc/profile.d
echo '{ ping -c 1 $(cat /etc/fstab|grep nfs.remote|cut -d : -f1) >/dev/null 2>&1; } && [ -f /nfs.remote/shell.inc ] && source /nfs.remote/shell.inc' > /etc/profile.d/load_remote_shell.sh
echo 'load remote shell add ok'

}

cat /etc/fstab


