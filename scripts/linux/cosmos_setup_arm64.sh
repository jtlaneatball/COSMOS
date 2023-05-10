#!/usr/bin/env sh

set -e

# This will perform additional build environment setup to allow the cosmos 5 docker images to
# be built for arm64 on a build machine. It will create a local docker registry to store base images
# and create a buildx docker builder for cross platform docker image building.

# REQUIRED: docker, docker-compose, docker buildx, docker desktop is required for building images for arm64,
# docker desktop has all of the qemu emulation built in. Alternatively, all required qemu packages could be installed

# Change to the root cosmos directory to access files more easily
DIRECTORY=$(cd `dirname $0` && pwd)
cd $DIRECTORY/../..

scripts/linux/cosmos_setup.sh

docker buildx version
if [ "$?" -ne 0 ]; then
  echo "ERROR: docker buildx is not installed, please install and try again." 1>&2
  echo "${0} FAILED" 1>&2
  exit 1
fi

# Check if the local registry container is already created and running,
# run the container if necessary
if [ ! "$(docker ps -q -f name=cosmos5-install-registry 2> /dev/null)" ]; then
    echo "cosmos registry is not running"
    if [ "$(docker ps -aq -f status=exited -f name=cosmos5-install-registry 2> /dev/null)" ]; then
        echo "cosmos registry is stopped"
        docker rm cosmos5-install-registry &>/dev/null
    fi
    echo "running cosmos registry..."
    docker run -d -p 5151:5000 --restart=always --name cosmos5-install-registry registry:2 &>/dev/null
else
    echo "cosmos registry is already running."
fi

# Check if the cosmos5 builder already exists and create it if not
if [ ! "$(docker buildx ls | grep 'cosmos5-builder0' 2> /dev/null)" ]; then
    echo "creating cosmos multi-arch builder"
    docker buildx create --platform linux/arm64,linux/amd64,windows/amd64 --driver-opt network=host --name cosmos5-builder &>/dev/null
else
    echo "cosmos multi-arch builder already exists."
fi

# switch to and run the cosmos builder
docker buildx use cosmos5-builder &>/dev/null
docker buildx inspect --bootstrap &>/dev/null

# copy ssl certificate to builder container
docker cp cosmos-ruby/cacert.pem buildx_buildkit_cosmos5-builder0:/usr/local/share/ca-certificates/ca-certificates.crt
# update ssl certificates in builder container
docker exec -d buildx_buildkit_cosmos5-builder0 update-ca-certificates