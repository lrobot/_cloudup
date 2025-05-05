

mkdir -p /nfs.remote
if [ -f /opt/_cloudup/nfs.remote/shell.inc ] && [ ! -f /nfs.remtoe/shell.inc ] ; then
  mount -o bind /opt/_cloudup/nfs.remote /nfs.remote
fi


if [ ! -e ~/file ]; then
  mkdir -p /_data/opt/_cloudup/file_rbat_tk
  ln -s /_data/opt/_cloudup/file_rbat_tk file
fi

