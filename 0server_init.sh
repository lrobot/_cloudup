

mkdir -p /nfs.remote
if [ -f /_cloudup/nfs.remote/shell.inc ] && [ ! -f /nfs.remtoe/shell.inc ] ; then
  mount -o bind /_cloudup/nfs.remote /nfs.remote
fi

if [ -f /_cloudup/nfs.remote/shell.inc ] ; then
cat <<EOF | tee /etc/profile.d/cloudup_nfsremote_shell.sh
[ -f /_cloudup/nfs.remote/shell.inc ] && source /_cloudup/nfs.remote/shell.inc
EOF
fi

if [ ! -e ~/file ]; then
  mkdir -p /_data/_cloudup/file_rbat_tk
  ln -s /_data/_cloudup/file_rbat_tk file
fi

