
mkdir -p /opt && cd /opt && (

mkdir -p _certbot/etc_letsencrypt _certbot/var_lib_letsencrypt _certbot/var_log_letsencrypt
echo -d www.domain.com
podman run --rm -it --net=host -v ./_certbot/etc_letsencrypt:/etc/letsencrypt -v ./_certbot/var_lib_letsencrypt:/var/lib/letsencrypt -v ./_certbot/var_log_letsencrypt:/var/log/letsencrypt certbot/certbot certonly --standalone --force-renewal --no-eff-email --agree-tos --email lrobot.qq@gmail.com -v $@

)



