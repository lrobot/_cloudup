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
# _local_domain_name=$1
[ "x$_local_domain_name" == "x" ] && _local_domain_name=$env_domain_name_inet
[ "x$_local_domain_name" == "x" ] && _local_domain_name=inet.$env_domain_name
[ "x$_local_domain_name" == "x" ] && {
  echo "no domain name"
  exit
}


CONTAINER_NAME=${_local_domain_name//./_}_webui
DATA_DIR=/_data${SCRIPT_DIR}/${CONTAINER_NAME}
mkdir -p ${DATA_DIR}

__label_file() {
  # traefik.docker.network
cat <<EOF
traefik.enable=true
traefik.http.routers.rt_${CONTAINER_NAME}_http.rule=Host(\`${_local_domain_name}\`) && PathPrefix(\`/web\`)
traefik.http.routers.rt_${CONTAINER_NAME}_http.entrypoints=ep_web
traefik.http.routers.rt_${CONTAINER_NAME}_http.middlewares=mw_rs_http2https
traefik.http.routers.rt_${CONTAINER_NAME}_https.rule=Host(\`${_local_domain_name}\`) && PathPrefix(\`/web\`)
traefik.http.routers.rt_${CONTAINER_NAME}_https.entrypoints=ep_webtls
traefik.http.routers.rt_${CONTAINER_NAME}_https.tls.certresolver=myresolver
traefik.http.routers.rt_${CONTAINER_NAME}_https.service=srv_${CONTAINER_NAME}
traefik.http.services.srv_${CONTAINER_NAME}.loadbalancer.server.port=8080
EOF
}

if podman container exists ${CONTAINER_NAME}; then
  podman exec -it ${CONTAINER_NAME} sh
else
echodo __label_file
podman stop ${CONTAINER_NAME}
podman rm ${CONTAINER_NAME}
cat config.yaml | sed "s/headscale.domain.com/${_local_domain_name}/" > ${DATA_DIR}/config.yaml
podman run --rm \
  --detach \
  --name ${CONTAINER_NAME} \
  --label-file <(__label_file) \
  ghcr.io/gurucomputing/headscale-ui
echo https://${_local_domain_name}/web/
fi

