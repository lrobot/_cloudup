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
cd ${SCRIPT_DIR}

_local_domain_name=$1
[ "x$_local_domain_name" == "x" ] && _local_domain_name=$env_domain_name_drone
[ "x$_local_domain_name" == "x" ] && _local_domain_name=drone.$env_domain_name
[ "x$_local_domain_name" == "x" ] && {
  echo "no domain name"
  exit
}
CONTAINER_NAME=${_local_domain_name//./_}


DATA_DIR=/_data${SCRIPT_DIR}/${CONTAINER_NAME}
echodo mkdir -p ${DATA_DIR}
echodo podman stop ${CONTAINER_NAME}
echodo podman rm ${CONTAINER_NAME}

__label_file() {
cat <<EOF
traefik.enable=true
traefik.http.routers.rt_${CONTAINER_NAME}.rule=Host(\`${_local_domain_name}\`)
traefik.http.routers.rt_${CONTAINER_NAME}.entrypoints=ep_webtls
traefik.http.routers.rt_${CONTAINER_NAME}.tls.certresolver=myresolver
EOF
}

run_with_notls() {

echodo podman run --name ${CONTAINER_NAME} -d \
--restart unless-stopped \
-e DRONE_GITEE_CLIENT_ID=1a782095fad7b857d7adede6e05231ccd48adf2fc81683dc17724141a8673ff1 \
-e DRONE_GITEE_CLIENT_SECRET=2c31bc17d72a5a2295a06989748b8b2ea1a32c03747f6b74a218fba0120c44ad \
-e DRONE_RPC_SECRET=77a08c9efb88d965a9940de554fb76da \
-e DRONE_SERVER_HOST=${_local_domain_name} \
-e DRONE_SERVER_PROTO=https \
-p 1445:443 \
-v ${DATA_DIR}:/data \
--label-file <(__label_file) \
drone/drone:2

}


run_with_notls
