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
CONTAINER_NAME=qfilexchange_containerbox
DATA_DIR=/_data/${SCRIPT_DIR}/${CONTAINER_NAME}
echodo mkdir -p ${DATA_DIR}
echodo podman stop ${CONTAINER_NAME}
echodo podman rm ${CONTAINER_NAME}

#-p 8085:5000  
echodo podman run --name ${CONTAINER_NAME} -d \
-p 443:443 \
-v ./_certbot/etc_letsencrypt:/certs \
-v ${DATA_DIR}:/registry \
-e STORAGE_PATH=/registry \
-e REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY=/registry \
-e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/live/zyb.danfestar.cn/fullchain.pem \
-e REGISTRY_HTTP_TLS_KEY=/certs/live/zyb.danfestar.cn/privkey.pem \
docker.io/registry:2

