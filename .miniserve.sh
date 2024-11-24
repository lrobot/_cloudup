#!/usr/bin/env bash
#from mypriv.sh  #test fromat not support by dash [[]]
if [[ "x$BB_ASH_VERSION" != "x" ]] ; then SCRIPT=$0; if [[ "x${SCRIPT}" == "x-ash" ]]; then SCRIPT=$1; fi; SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${SCRIPT}")" && pwd) ; fi
if [[ "x$ZSH_VERSION" != "x" ]] ; then SCRIPT_DIR=${0:a:h} ; fi
if [[ "x$BASH_VERSION" != "x" ]] ; then SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )" ; fi
if [[ "x$SHELL" == "x/bin/ash" ]] ; then SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) ; fi
if [[ "x$SCRIPT_DIR" == "x" ]] ; then SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) ; fi #some busybox early version ont SHELL env var
if [[ "x$SCRIPT_DIR" == "x" ]] ; then echo waring can not get SCRIPT_DIR, dont trust use it ; fi
#[[ "x$0" == "x-ash" ]]  is source ash script case
#
echodo() { echo _run_cmd:"$@"; $@; }

if [ "x$1" == "" ] ; then
  echo "Usage: $0 <domain_name> dir"
  exit 1
fi

DOMAIN_NAME=${1}
CONTAINER_NAME=${DOMAIN_NAME//./_}
DATA_DIR=$2
echodo mkdir -p ${DATA_DIR}
echodo podman stop ${CONTAINER_NAME}
echodo podman rm ${CONTAINER_NAME}


__label_file() {
  # traefik.docker.network
cat <<EOF
traefik.enable=true
traefik.http.routers.${CONTAINER_NAME}.rule=Host(\`${DOMAIN_NAME}\`)
traefik.http.routers.${CONTAINER_NAME}.entrypoints=websecure
traefik.http.routers.${CONTAINER_NAME}.tls.certresolver=myresolver
traefik.http.routers.${CONTAINER_NAME}.service=${CONTAINER_NAME}_service
traefik.http.services.${CONTAINER_NAME}_service.loadbalancer.server.port=8080
EOF
}

#-p 8080:8080
echodo podman run --name ${CONTAINER_NAME} -d -it --label-file <(__label_file)  -v ./${DATA_DIR}:/tmp  docker.io/svenstaro/miniserve --index index.html /tmp