#!/usr/bin/env bash

CONTAINER_NAME="cloudup_pub"



if podman container exists "$CONTAINER_NAME"; then
  echo ${CONTAINER_NAME} exist
  podman stop ${CONTAINER_NAME}
fi

echo ${CONTAINER_NAME} creating...
podman run -d --rm --name ${CONTAINER_NAME} \
 -v /nfs.local/_cloudup/cloudup:/cloudup_pub --rm -p 80:8080 svenstaro/miniserve  /cloudup_pub

podman generate systemd ${CONTAINER_NAME} > /etc/systemd/system/qcontainer-${CONTAINER_NAME}.service
systemctl enable qcontainer-${CONTAINER_NAME}.service
echo ${CONTAINER_NAME} showlog
podman logs -f "${CONTAINER_NAME}"

