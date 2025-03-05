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

#this is simple, can not add client2client peer
#maybe try: https://github.com/ngoduykhanh/wireguard-ui

_local_domain_name=$1
[ "x$_local_domain_name" == "x" ] && _local_domain_name=$env_domain_name_wireguard
[ "x$_local_domain_name" == "x" ] && _local_domain_name=wireguard.$env_domain_name
[ "x$_local_domain_name" == "x" ] && {
  echo "no domain name"
  exit
}


#https://github.com/wg-easy/wg-easy/blob/master/How_to_generate_an_bcrypt_hash.md
#https://github.com/wg-easy/wg-easy/wiki/Using-WireGuard-Easy-with-Podman
#https://github.com/wg-easy/wg-easy/wiki/Using-WireGuard-Easy-with-Traefik-SSL
# podman run --rm -it ghcr.io/wg-easy/wg-easy wgpw 'your_admin_password'


echo_container_label() {
##this common cfg
cat <<EOF
traefik.enable=true
traefik.http.middlewares.mw_rs_http2https.redirectscheme.scheme=https
traefik.http.middlewares.mw_rs_http2https.redirectscheme.permanent=true
traefik.http.middlewares.mw_rs_http2tls9443.redirectscheme.scheme=https
traefik.http.middlewares.mw_rs_http2tls9443.redirectscheme.permanent=true
traefik.http.middlewares.mw_rs_http2tls9443.redirectscheme.port=9443
traefik.http.middlewares.mv_ba_traefikauth.basicAuth.users=${_local_env_admin_auth_str}
traefik.http.middlewares.mv_sp_test.stripprefix.prefixes=/test_remove_traefik_prefix

traefik.http.services.WireGuardService.loadbalancer.server.port=51821
traefik.http.routers.WireGuardRoute.service=WireGuardService
traefik.http.routers.WireGuardRoute.rule=Host(\`$1\`)
traefik.http.routers.WireGuardRoute.entrypoints=ep_web
traefik.http.routers.WireGuardRoute.middlewares=mw_rs_http2https
traefik.http.routers.WireGuardRouteSSL.service=WireGuardService
traefik.http.routers.WireGuardRouteSSL.rule=Host(\`$1\`)
traefik.http.routers.WireGuardRouteSSL.entrypoints=ep_webtls
traefik.http.routers.WireGuardRouteSSL.tls.certresolver=myresolver
EOF
}
echodo echo_container_label $_local_domain_name
# podman run --rm -it ghcr.io/wg-easy/wg-easy wgpw 'your_admin_password'
#  --restart unless-stopped
#  \
CONTAINER_NAME=${_local_domain_name//./_}
DATA_DIR=/_data${SCRIPT_DIR}/${CONTAINER_NAME}
mkdir -p ${DATA_DIR}
podman stop ${CONTAINER_NAME}
podman rm ${CONTAINER_NAME}
echo starting
# PASSWORD_HASH set as here
eval $(podman run --rm ghcr.io/wg-easy/wg-easy wgpw ${env_admin_password})
podman run --rm -d \
  --name=${CONTAINER_NAME} \
  -e WG_HOST=${_local_domain_name} \
  -e PASSWORD_HASH=${PASSWORD_HASH} \
  -v ${DATA_DIR}:/etc/wireguard \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  --cap-add=NET_RAW \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  --sysctl="net.ipv4.ip_forward=1" \
  --label-file <(echo_container_label $_local_domain_name) \
  --entrypoint "" \
  ghcr.io/wg-easy/wg-easy \
  docker-entrypoint.sh /usr/bin/dumb-init node server.js

