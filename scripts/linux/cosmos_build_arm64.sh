#!/usr/bin/env sh

set -e

# Change to the root cosmos directory to access files more easily
DIRECTORY=$(cd `dirname $0` && pwd)
cd $DIRECTORY/../..

export $(cat .env | grep -v "#" | xargs)

# scripts/linux/cosmos_setup_arm64.sh

# Buildx for multi-arch does not check the locally installed images.
# It must pull base images from a registry, so push our base images to a local registry.

docker pull --platform ${PLATFORM} alpine:${ALPINE_VERSION}.${ALPINE_BUILD}
docker tag alpine:${ALPINE_VERSION}.${ALPINE_BUILD} ${COSMOS_REGISTRY}/alpine:${ALPINE_VERSION}.${ALPINE_BUILD}
docker push ${COSMOS_REGISTRY}/alpine:${ALPINE_VERSION}.${ALPINE_BUILD}

docker pull --platform ${PLATFORM} minio/minio:RELEASE.2021-06-17T00-10-46Z
docker tag minio/minio:RELEASE.2021-06-17T00-10-46Z ${COSMOS_REGISTRY}/minio/minio:RELEASE.2021-06-17T00-10-46Z
docker push ${COSMOS_REGISTRY}/minio/minio:RELEASE.2021-06-17T00-10-46Z

docker pull --platform ${PLATFORM} minio/mc:RELEASE.2021-12-10T00-14-28Z
docker tag minio/mc:RELEASE.2021-12-10T00-14-28Z ${COSMOS_REGISTRY}/minio/mc:RELEASE.2021-12-10T00-14-28Z
docker push ${COSMOS_REGISTRY}/minio/mc:RELEASE.2021-12-10T00-14-28Z

docker pull --platform ${PLATFORM} redis:6.2
docker tag redis:6.2 ${COSMOS_REGISTRY}/redis:6.2
docker push ${COSMOS_REGISTRY}/redis:6.2

docker pull --platform ${PLATFORM} traefik:2.7.0
docker tag traefik:2.7.0 ${COSMOS_REGISTRY}/traefik:2.7.0
docker push ${COSMOS_REGISTRY}/traefik:2.7.0

docker buildx bake --set *.platform=${PLATFORM} --load --no-cache -f compose.yaml -f compose-build.yaml --progress=plain cosmos-ruby
docker push ${COSMOS_REGISTRY}/ballaerospace/cosmosc2-ruby:${COSMOS_TAG}

docker buildx bake --set *.platform=${PLATFORM} --load --no-cache -f compose.yaml -f compose-build.yaml --progress=plain cosmos-base
docker push ${COSMOS_REGISTRY}/ballaerospace/cosmosc2-base:${COSMOS_TAG}

docker buildx bake --set *.platform=${PLATFORM} --load --no-cache -f compose.yaml -f compose-build.yaml --progress=plain cosmos-node
docker push ${COSMOS_REGISTRY}/ballaerospace/cosmosc2-node:${COSMOS_TAG}

docker buildx bake --set *.platform=${PLATFORM} --load --no-cache -f compose.yaml -f compose-build.yaml --progress=plain \
    cosmos-minio \
    cosmos-redis \
    cosmos-cmd-tlm-api \
    cosmos-script-runner-api \
    cosmos-operator \
    cosmos-traefik \
    cosmos-init