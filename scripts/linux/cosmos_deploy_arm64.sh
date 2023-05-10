#!/usr/bin/env sh

set -e

# This script will save all of the arm64 docker images to a folder so that they can be copied to the target machine.
# It also copies the .env and compose.yaml files that are needed to run the images on the target machine.
# It also copies the cosmos_load_arm64.sh script which should be run on the target machine to load all of the docker images for use

COSMOS_DIRECTORY=$(cd `dirname $0` && pwd)/../..

if [ "$#" -eq 0 ]; then
  mkdir -p $COSMOS_DIRECTORY/arm64-install-files
  cd $COSMOS_DIRECTORY/arm64-install-files
elif [ "$#" -gt 1 ]; then
  echo "Usage: Provide the absolute path to desired output directory."
  echo "If no path is provided, will default to <cosmos-root-directory>/arm64-install-files/"
  exit 1
else
  if [ -d "$1" ]; then
    cd "$1"
  else
    echo "$1 does not exist or is not a directory. Exiting..."
    exit 1
  fi
fi

echo "Saving files to $(pwd)"

export $(cat $COSMOS_DIRECTORY/.env | grep -v "#" | xargs)

# save all docker images to the install directory. ruby, base, and node may not be necessary since they're base images of the others
# docker save -o cosmos-ruby.docker ballaerospace/cosmosc2-ruby:${COSMOS_TAG}
# docker save -o cosmos-base.docker ballaerospace/cosmosc2-base:${COSMOS_TAG}
# docker save -o cosmos-node.docker ballaerospace/cosmosc2-node:${COSMOS_TAG}
docker save -o cosmosc2-cmd-tlm-api.docker ballaerospace/cosmosc2-cmd-tlm-api:${COSMOS_TAG}
docker save -o cosmosc2-init.docker ballaerospace/cosmosc2-init:${COSMOS_TAG}
docker save -o cosmosc2-minio.docker ballaerospace/cosmosc2-minio:${COSMOS_TAG}
docker save -o cosmosc2-operator.docker ballaerospace/cosmosc2-operator:${COSMOS_TAG}
docker save -o cosmosc2-redis.docker ballaerospace/cosmosc2-redis:${COSMOS_TAG}
docker save -o cosmosc2-script-runner-api.docker ballaerospace/cosmosc2-script-runner-api:${COSMOS_TAG}
docker save -o cosmosc2-traefik.docker ballaerospace/cosmosc2-traefik:${COSMOS_TAG}

# cosmos 5 also needs minio to run, so save the arm64 image
# docker pull minio/minio:RELEASE.2021-06-17T00-10-46Z@sha256:2bf13dd19c522585bca418abfac3783b328d723740758fdbe72fde61c55e4fdc
# docker save -o minio.docker minio/minio

cp $COSMOS_DIRECTORY/.env .
cp $COSMOS_DIRECTORY/cacert.pem .
cp $COSMOS_DIRECTORY/compose.yaml .
cp $COSMOS_DIRECTORY/scripts/linux/cosmos_load_arm64.sh .
cp $COSMOS_DIRECTORY/cosmos-control.sh .