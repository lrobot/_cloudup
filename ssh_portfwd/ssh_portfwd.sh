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
set -x

echodo() { echo _run_cmd:"$@"; $@; }
cd ${SCRIPT_DIR}

CONTAINER_NAME=ssh_portfwd


echodo podman stop ${CONTAINER_NAME}
echodo podman rm ${CONTAINER_NAME}


#-p 2222:2222 \
echodo podman run --name ${CONTAINER_NAME} -d \
--restart unless-stopped \
--network=host \
-e USER_NAME=sshtunnel -e USER_PASSWORD=891c4af952dc2d1fd8e4251b8481038c -e LOG_STDOUT=true -e PASSWORD_ACCESS=true  -v `pwd`/config:/config linuxserver/openssh-server:version-10.0_p1-r9

#podman run --rm -it -p 2222:2222 -e USER_NAME=sshtunnel -e USER_PASSWORD=891c4af952dc2d1fd8e4251b8481038c -e LOG_STDOUT=true -e PASSWORD_ACCESS=true  -v ./config:/config linuxserver/openssh-server sh


