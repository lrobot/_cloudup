#!/usr/bin/env bash

#_local_domain_name=$1
[ "x$_local_domain_name" == "x" ] && _local_domain_name=$env_domain_name_meeting
[ "x$_local_domain_name" == "x" ] && _local_domain_name=meeting.$env_domain_name
[ "x$_local_domain_name" == "x" ] && {
  echo "no domain name"
  exit
}


echo_compose_env() {
cat <<EOF
KMEETING_DOMAIN_NAME=${_local_domain_name}
EOF
}
tempfile=$(mktemp .__meeting_compose_XXXXXXXXXX)
echo_compose_env > $tempfile
cat $tempfile
podman-compose --env-file $tempfile "$@"
rm -f $tempfile

