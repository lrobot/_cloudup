#!/bin/bash
set -x

# https://docs.zerotier.com/relay/
#
podman stop zerotier_one
podman rm zerotier_one > /dev/null 2>&1
podman run -d --name zerotier_one --network=host --cap-add NET_ADMIN --device /dev/net/tun -v /var/lib/zerotier-one:/var/lib/zerotier-one zerotier/zerotier:latest


cat <<EOF
todo tips:
vi /var/lib/zerotier-one/local.conf
{ "settings": { "tcpFallbackRelay": "1.2.3.4/8445", "forceTcpRelay": true } }
EOF


podman logs -f zerotier_one

