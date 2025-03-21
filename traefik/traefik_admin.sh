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
[ "x$_local_domain_name" == "x" ] && _local_domain_name=$env_domain_name_admin
[ "x$_local_domain_name" == "x" ] && _local_domain_name=admin.$env_domain_name


if ping -c 3 $_local_domain_name > /dev/null ; then
  echo ping ok for:$_local_domain_name
else
  echo ping err for:$_local_domain_name
  _local_domain_name=''
fi

CONTAINER_NAME=traefik_admin
if [ "x${_local_domain_name}" != "x" ] ; then
  which htpasswd > /dev/null || { apt update && apt install -y apache2-utils; }
  _local_env_admin_password_hash=$(htpasswd -nbm admin ${env_admin_password})
fi
export env_admin_password=""

mkdir -p __traefik_tmp_data

echo_container_label() {
##this common cfg
cat <<EOF
traefik.enable=true
traefik.http.middlewares.mw_rs_http2https.redirectscheme.scheme=https
traefik.http.middlewares.mw_rs_http2https.redirectscheme.permanent=true
traefik.http.middlewares.mw_rs_http2tls8443.redirectscheme.scheme=https
traefik.http.middlewares.mw_rs_http2tls8443.redirectscheme.permanent=true
traefik.http.middlewares.mw_rs_http2tls8443.redirectscheme.port=8443
EOF

if [ "x$1" != "x" ]; then
# 
# if no traefik.http.routers.rt_traefik_dashboard.entrypoints, default use all entrypoints
cat <<EOF
#80->8443
traefik.http.routers.rt_traefik_80.rule=Host(\`${1}\`)
traefik.http.routers.rt_traefik_80.entrypoints=ep_web
traefik.http.routers.rt_traefik_80.middlewares=mw_rs_http2tls8443
#443->8443
traefik.http.routers.rt_traefik_443.rule=Host(\`${1}\`)
traefik.http.routers.rt_traefik_443.entrypoints=ep_webtls
traefik.http.routers.rt_traefik_443.tls.certresolver=myresolver
traefik.http.routers.rt_traefik_443.middlewares=mw_rs_http2tls8443

#8443 /redirct to /traefik
traefik.http.routers.rt_traefik_root.rule=Host(\`${1}\`) && Path(\`/\`)
traefik.http.routers.rt_traefik_root.entrypoints=ep_webtls8k
traefik.http.routers.rt_traefik_root.tls.certresolver=myresolver
traefik.http.routers.rt_traefik_root.middlewares=mw_rr_traefik
traefik.http.middlewares.mw_rr_traefik.redirectregex.regex=^https://${1}:8443/?$
traefik.http.middlewares.mw_rr_traefik.redirectregex.replacement=https://${1}:8443/traefik

#8443 need auto for access api@internal
traefik.http.middlewares.mv_ba_traefikauth.basicAuth.users=${_local_env_admin_password_hash}
traefik.http.middlewares.mv_sp_test.stripprefix.prefixes=/test_remove_traefik_prefix
traefik.http.routers.rt_traefik_dashboard.rule=Host(\`${1}\`) && (PathPrefix(\`/traefik\`) || PathPrefix(\`/test_remove_traefik_prefix\`))
traefik.http.routers.rt_traefik_dashboard.entrypoints=ep_webtls8k
traefik.http.routers.rt_traefik_dashboard.tls.certresolver=myresolver
traefik.http.routers.rt_traefik_dashboard.service=api@internal
traefik.http.routers.rt_traefik_dashboard.middlewares=mv_ba_traefikauth,mv_sp_test

#9080 / redirct to /traefik
traefik.http.routers.rt_traefik_9080_root.rule=HostRegexp(\`^.*$\`) && Path(\`/\`)
traefik.http.routers.rt_traefik_9080_root.entrypoints=ep_web9k
traefik.http.routers.rt_traefik_9080_root.middlewares=mw_rr_traefik9080
traefik.http.middlewares.mw_rr_traefik9080.redirectregex.regex=^http://([^/]+)/$
traefik.http.middlewares.mw_rr_traefik9080.redirectregex.replacement=http://\$1/traefik

#9080 can access without auth
traefik.http.routers.rt_traefik_9080.rule=HostRegexp(\`^.*$\`)
traefik.http.routers.rt_traefik_9080.entrypoints=ep_web9k
traefik.http.routers.rt_traefik_9080.service=api@internal
EOF
fi

}
echodo podman stop ${CONTAINER_NAME}
echodo podman rm -f ${CONTAINER_NAME}
echodo echo_container_label $_local_domain_name
podman run --rm -d \
	--name ${CONTAINER_NAME} \
	-p 80:80 \
	-p 443:443 \
	-p 8080:8080 \
	-p 8443:8443 \
	-p 9080:9080 \
	-v ./traefik.yml:/traefik.yml \
	-v ./__traefik_tmp_data:/__traefik_tmp_data \
	-v ./traefik_file_provider:/traefik_file_provider \
	-v /run/podman/podman.sock:/var/run/docker.sock:ro \
	--label-file <(echo_container_label $_local_domain_name) \
	traefik:3.3 \
	--configfile=/traefik.yml

#--api=true
#--api.insecure=true
#--providers.docker=true
#--entrypoints.ep_web.address=:80
#--entrypoints.ep_webtls.address=:443
#--certificatesresolvers.myresolver.acme.tlschallenge=true
#--certificatesresolvers.myresolver.acme.email=lrobot.qq@gmail.com
#--certificatesresolvers.myresolver.acme.storage=/__traefik_tmp_data/acme.json


