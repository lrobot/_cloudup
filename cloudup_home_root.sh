#!/usr/bin/env bash

CONTAINER_NAME="cloudup_home_root"



if podman container exists "$CONTAINER_NAME"; then
  echo ${CONTAINER_NAME} exist
  podman stop ${CONTAINER_NAME}
fi

echo ${CONTAINER_NAME} creating...
podman run -d --rm --name ${CONTAINER_NAME} \
 -v /nfs.local/_cloudup/:/cloudup_home_root --rm -p 8080:8080 svenstaro/miniserve  /cloudup_home_root

podman generate systemd ${CONTAINER_NAME} > /etc/systemd/system/qcontainer-${CONTAINER_NAME}.service
systemctl enable qcontainer-${CONTAINER_NAME}.service
echo ${CONTAINER_NAME} showlog
podman logs -f "${CONTAINER_NAME}"

