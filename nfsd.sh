

# https://wiki.debian.org/NFSServerSetup
grep NFSD /boot/config-`uname -r`
apt install -y nfs-kernel-server rpcbind
perl -pi -e 's/^OPTIONS/#OPTIONS/' /etc/default/rpcbind
echo "rpcbind: ALL" >> /etc/hosts.allow

cat <<EOF > /etc/nfs.conf
#
# This is a general configuration for the
# NFS daemons and tools
#
[general]
pipefs-directory=/run/rpc_pipefs
#
[nfsrahead]
# nfs=15000
# nfs4=16000
#
[exports]
# rootdir=/export
#
[exportfs]
# debug=0
#
[gssd]
# verbosity=0
# rpc-verbosity=0
# use-memcache=0
# use-machine-creds=1
# use-gss-proxy=0
# avoid-dns=1
# limit-to-legacy-enctypes=0
# context-timeout=0
# rpc-timeout=5
# keytab-file=/etc/krb5.keytab
# cred-cache-directory=
# preferred-realm=
# set-home=1
# upcall-timeout=30
# cancel-timed-out-upcalls=0
#
[lockd]
port=7101
udp-port=7102
#
[exportd]
# debug="all|auth|call|general|parse"
# manage-gids=n
# state-directory-path=/var/lib/nfs
# threads=1
# cache-use-ipaddr=n
# ttl=1800
[mountd]
# debug="all|auth|call|general|parse"
manage-gids=y
# descriptors=0
port=7103
# threads=1
# reverse-lookup=n
# state-directory-path=/var/lib/nfs
# ha-callout=
# cache-use-ipaddr=n
# ttl=1800
#
[nfsdcld]
# debug=0
# storagedir=/var/lib/nfs/nfsdcld
#
[nfsdcltrack]
# debug=0
# storagedir=/var/lib/nfs/nfsdcltrack
#
[nfsd]
# debug=0
# threads=8
# host=
# port=2049
# grace-time=90
# lease-time=90
# udp=n
# tcp=y
# vers3=y
# vers4=y
# vers4.0=y
# vers4.1=y
# vers4.2=y
# rdma=n
# rdma-port=20049

[statd]
# debug=0
port=7105
outgoing-port=7106
# name=
# state-directory-path=/var/lib/nfs/statd
# ha-callout=
# no-notify=0
#
[sm-notify]
# debug=0
# force=0
# retry-time=900
outgoing-port=7107
# outgoing-addr=
# lift-grace=y
#
[svcgssd]
# principal=
EOF

cat <<EOF > /etc/sysctl.d/nfs-static-ports.conf
#fs.nfs.nfs_callback_tcpport = 7108
fs.nfs.nlm_tcpport = 7109
fs.nfs.nlm_udpport = 7110
EOF

exportfs -a
systemctl restart rpcbind.service
sysctl --system
systemctl restart nfs-kernel-server.service
systemctl restart nfs-server.service

cat /proc/fs/nfsd/versions
rpcinfo -p


