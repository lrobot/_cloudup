#!/bin/bash
set -x
let err=0
for k in $(seq 1 3)
do
    check_code=$(pgrep 'haproxy$')
    if [[ "$check_code" == "" ]]; then
        let err=$err+1
        sleep 1
        continue
    else
        let err=0
        break
    fi
done

if [[ "$err" != "0" ]]; then
    echo "systemctl stop keepalived"
    /etc/init.d/keepalived stop
    exit 1
else
    exit 0
fi

