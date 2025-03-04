

podman run -d traefik:3.2.1 \
       	-p 80:80 -p 443:443 -p 9001:8080 \
	-v ./traefik.yml:/traefik.yml \
	-v ./_traefik:/_traefik \
	-v ./traefik_file_provider:/traefik_file_provider \
        -v /run/podman/podman.sock:/var/run/docker.sock:ro \
        --configfile=/traefik.yml

#--api=true
#--api.insecure=true
#--providers.docker=true
#--entrypoints.web.address=:80
#--entrypoints.websecure.address=:443
#--certificatesresolvers.myresolver.acme.tlschallenge=true
#--certificatesresolvers.myresolver.acme.email=lrobot.qq@gmail.com
#--certificatesresolvers.myresolver.acme.storage=/_traefik/acme.json


