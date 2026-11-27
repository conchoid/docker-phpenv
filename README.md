# Docker Images for phpenv

This repository contains Dockerfiles to install [madumlao/phpenv](https://github.com/madumlao/phpenv) within docker containers. Pre-build images are available at [Docker Hub](https://hub.docker.com/r/conchoid/docker-phpenv/).

## Build a multi-architecture OCI image

`8.5-trixie/Dockerfile` targets both `linux/amd64` and `linux/arm64`. The `git-lfs` binary is taken from the matching `conchoid/debian` tag via `TARGETARCH`.

```sh
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --output type=oci,dest=phpenv-oci.tar,name=conchoid/docker-phpenv:v1-1-8.5.13-trixie \
  -f 8.5-trixie/Dockerfile 8.5-trixie
```

The result is an OCI image archive containing a multi-platform index. To push it to a registry instead, replace `--output` with `--push` and use `-t conchoid/docker-phpenv:v1-1-8.5.13-trixie`.
