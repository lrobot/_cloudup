#!/usr/bin/env bash
set -x

CONTAINER_NAME="home_cftunnel"

CF_TOKEN=`cat /root/secret_dir/cftunnel_token.txt`


if podman container exists "$CONTAINER_NAME"; then
  echo ${CONTAINER_NAME} exist
  podman stop ${CONTAINER_NAME}
fi

echo ${CONTAINER_NAME} creating...
podman run -d --rm --name ${CONTAINER_NAME} \
 cloudflare/cloudflared:latest tunnel --no-autoupdate run --token $CF_TOKEN

podman generate systemd ${CONTAINER_NAME} > /etc/systemd/system/qcontainer-${CONTAINER_NAME}.service
systemctl enable qcontainer-${CONTAINER_NAME}.service
echo ${CONTAINER_NAME} showlog
podman logs -f "${CONTAINER_NAME}"

