
# https://docs.zerotier.com/relay/
#
podman stop zerotier_relay
podman rm zerotier_relay > /dev/null 2>&1
podman run -d --name zerotier_relay --init -p 8445:443 -p 9995:9993/udp --rm zerotier/pylon:latest reflect


