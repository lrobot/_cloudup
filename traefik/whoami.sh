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
if [ "x$1" == "x" ] ; then
   echo $0 <dommain_name>
   exit
else
DOMAIN_NAME=$1
fi


  whoami:
    image: traefik/whoami
    # ports:
    #   - "8007:80"
    labels:

CONTAINER_NAME=traefik_whoami
echodo podman stop ${CONTAINER_NAME}
echodo podman rm ${CONTAINER_NAME}


__label_file() {
cat <<EOF
traefik.enable=true
traefik.http.routers.whoamilocalhost.rule=Host(\`whoami.docker.localhost\`)
traefik.http.routers.whoami80.rule=Host(\`${DOMAIN_NAME}\`)
traefik.http.routers.whoami80.entrypoints=web
traefik.http.routers.whoami443.rule=Host(\`${DOMAIN_NAME}\`)
traefik.http.routers.whoami443.entrypoints=websecure
traefik.http.routers.whoami443.tls=true
traefik.http.routers.whoami443.tls.certresolver=myresolver
EOF
}


podman run -d --name ${CONTAINER_NAME}
  --label-file <(__label_file) \
  traefik/whoami

