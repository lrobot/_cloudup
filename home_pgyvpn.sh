#!/usr/bin/env bash

CONTAINER_NAME="pgy"

[ -e /dev/net/tun ] || {
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
}

if podman container exists "$CONTAINER_NAME"; then
  echo ${CONTAINER_NAME} exist
else
  echo ${CONTAINER_NAME} creating...
  podman run --name ${CONTAINER_NAME}  -d --device=/dev/net/tun --net=host --cap-add=NET_ADMIN --env PGY_USERNAME="70628622:001" --env PGY_PASSWORD="6zH9xdYYJuhqgF" crpi-orhk6a4lutw1gb13.cn-hangzhou.personal.cr.aliyuncs.com/bestoray/pgyvpn
fi
podman generate systemd ${CONTAINER_NAME} > /etc/systemd/system/qcontainer-${CONTAINER_NAME}.service
systemctl enable qcontainer-${CONTAINER_NAME}.service
echo ${CONTAINER_NAME} showlog
podman logs -f "${CONTAINER_NAME}"


