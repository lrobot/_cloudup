

if ! [ -d /mnt/hy_data ]; then
  echo "no /mnt/hy_data"
else
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset FTP_PROXY
  unset RSYNC_PROXY
  unset ALL_PROXY
  mkdir -p  /mnt/hy_data/data/ollama
  podman build --network host -f Dockerfile.ollama .
  podman run --rm -it -v /mnt/hy_data/data/ollama:/root/.ollama -p 11434:11434 --name ollama \
    `podman build --network host -f Dockerfile.ollama -q .`
    #ollama/ollama
fi
