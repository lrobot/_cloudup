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
CONTAINER_NAME=meeting
DATA_DIR=/_data${SCRIPT_DIR}/${CONTAINER_NAME}
echodo mkdir -p ${DATA_DIR}
echodo podman stop ${CONTAINER_NAME}
echodo podman rm ${CONTAINER_NAME}
echodo podman rmi qmeeting:latest

DOMAIN_NAME=meeting.danfestar.cn
#[ -f ./.env ] && source ./.env

#-p 8085:5000  

__label_file() {
cat <<EOF
traefik.enable=true
traefik.http.routers.${CONTAINER_NAME}.rule=Host(\`${DOMAIN_NAME}\`)
traefik.http.routers.${CONTAINER_NAME}.entrypoints=websecure
traefik.http.routers.${CONTAINER_NAME}.tls.certresolver=myresolver
EOF
}


echodo podman run --tls-verify=false --name ${CONTAINER_NAME} -d \
-p 9002:80 \
-v ${DATA_DIR}:/data \
--label-file <(__label_file) \
docker://registry.danfestar.cn/qmeeting:latest
echodo podman logs -f ${CONTAINER_NAME}

