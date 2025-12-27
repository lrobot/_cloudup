#!/usr/bin/env bash

CONTAINER_NAME="cfddns"


if podman container exists "$CONTAINER_NAME"; then
  echo ${CONTAINER_NAME} exist
else
  echo ${CONTAINER_NAME} creating...
  podman run -d --name ${CONTAINER_NAME} \
 --network host \
  -e CLOUDFLARE_API_TOKEN=ONVc5LpZsPUMcTGqKPbL-K2X7h0Qv7qDmrQHfBNS \
  -e DOMAINS=v6.danfestar.com \
  -e PROXIED=false \
  favonia/cloudflare-ddns:latest
fi
podman generate systemd ${CONTAINER_NAME} > /etc/systemd/system/qcontainer-${CONTAINER_NAME}.service
systemctl enable qcontainer-${CONTAINER_NAME}.service
echo ${CONTAINER_NAME} showlog
podman logs -f "${CONTAINER_NAME}"


