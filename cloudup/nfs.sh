#!/bin/sh

fstab_add() {
  local mount_host=$1
  local mount_path=$2
  grep -q ${mount_path} /etc/exports 2>/dev/null && {
    echo "${mount_path} this host export ${mount_path}, not do fstab_add"
    return 0;
  }
  mkdir -p /${mount_path}
  grep -q ${mount_path} /etc/fstab && {
    echo "${mount_path} already in /etc/fstab"
    return 0
  }
  echo ${mount_host}:/${mount_path} /${mount_path} nfs4  defaults,ro,nofail 0 0 >> /etc/fstab
}


ping -c 1 qdisk.lan > /dev/null 2>&1 && {
  fstab_add qdisk.lan nfs.local
}

# cloudup_=$(wget -q --no-check-certificate -O- http://gitee.com/lrobot/dev_info/raw/master/cloudup_url.txt)
# ping -c 1 ${cloudup_} > /dev/null 2>&1 && {
#   fstab_add ${cloudup_} nfs.remote
# }
