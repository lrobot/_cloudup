#!/bin/sh

# ref https://wiki.alpinelinux.org/wiki/K8s
echo xk8s.sh

echo "br_netfilter" > /etc/modules-load.d/k8s.conf
modprobe br_netfilter
sysctl net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
sysctl net.bridge.bridge-nf-call-iptables=1

apk add cni-plugin-flannel cni-plugins cni-plugin-flannel kubelet kubeadm kubectl containerd uuidgen nfs-utils
cp -av /etc/fstab /etc/fstab.bak_for_k8s_setup
sed -i '/swap/s/^/#/' /etc/fstab
swapoff -a


cat <<EOF | tee /etc/local.d/sharemetrics.start
#!/bin/sh
mount --make-rshared /
EOF
chmod +x /etc/local.d/sharemetrics.start
rc-update add local
#Fix id error messages
uuidgen > /etc/machine-id

rc-update add containerd
rc-update add kubelet
rc-service containerd start
