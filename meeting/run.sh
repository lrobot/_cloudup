podman stop kurento
podman rm kurento

echo $0 www.domain.com

if [ "x$1" == x ] ;then
  podman run -d --name kurento --rm --network host -v `pwd`/kurento.conf.json:/etc/kurento/kurento.conf.json kurento/kurento-media-server:7.0.0
  podman logs -f kurento
else
  domain=$1
  cat /etc/letsencrypt/live/$domain/{fullchain,privkey}.pem > _cert_key.pem
  podman run -d --name kurento --rm --network host -v `pwd`/kurento.conf.json:/etc/kurento/kurento.conf.json -v `pwd`/_cert_key.pem:/etc/kurento/_cert_key.pem kurento/kurento-media-server:7.0.0
  podman logs -f kurento
fi

