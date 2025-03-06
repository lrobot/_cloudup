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
[ "x$_local_domain_name" == "x" ] && _local_domain_name=$env_domain_name_inet
[ "x$_local_domain_name" == "x" ] && _local_domain_name=inet.$env_domain_name
[ "x$_local_domain_name" == "x" ] && {
  echo "no domain name"
  exit
}


CONTAINER_NAME=${_local_domain_name//./_}
podman exec -it ${CONTAINER_NAME} sh -c "headscale nodes list; headscale users list; headscale apikey list; headscale routes list;"
