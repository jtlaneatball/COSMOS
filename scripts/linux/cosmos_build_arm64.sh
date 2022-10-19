#!/usr/bin/env sh

set -e

# Change to the root cosmos directory to access files more easily
DIRECTORY=$(cd `dirname $0` && pwd)
cd $DIRECTORY/../..

export $(cat .env | grep -v "#" | xargs)

# scripts/linux/cosmos_setup_arm64.sh

# Buildx for multi-arch does not check the locally installed images.
# It must pull base images from a registry, so push our base images to a local registry.

docker pull minio/minio:RELEASE.2021-06-17T00-10-46Z@sha256:2bf13dd19c522585bca418abfac3783b328d723740758fdbe72fde61c55e4fdc
docker tag minio/minio:RELEASE.2021-06-17T00-10-46Z ${COSMOS_REGISTRY}/minio/minio:RELEASE.2021-06-17T00-10-46Z
docker push ${COSMOS_REGISTRY}/minio/minio:RELEASE.2021-06-17T00-10-46Z

docker pull minio/mc:RELEASE.2021-12-10T00-14-28Z@sha256:410ae817a76fbcc66a5fa06284f4823b9d834978aa8b7ff382862c28bffaf19a
docker tag minio/mc:RELEASE.2021-12-10T00-14-28Z ${COSMOS_REGISTRY}/minio/mc:RELEASE.2021-12-10T00-14-28Z
docker push ${COSMOS_REGISTRY}/minio/mc:RELEASE.2021-12-10T00-14-28Z

docker buildx bake --set *.platform=linux/arm64 --load --no-cache -f compose.yaml -f compose-build.yaml --progress=plain cosmos-ruby
docker push ${COSMOS_REGISTRY}/ballaerospace/cosmosc2-ruby:${COSMOS_TAG}
# docker tag ballaerospace/cosmosc2-ruby:${COSMOS_TAG} localhost:5151/cosmosc2-ruby:${COSMOS_TAG}
# docker push localhost:5151/cosmosc2-ruby:${COSMOS_TAG}

docker buildx bake --set *.platform=linux/arm64 --load --no-cache -f compose.yaml -f compose-build.yaml --progress=plain cosmos-base
docker push ${COSMOS_REGISTRY}/ballaerospace/cosmosc2-base:${COSMOS_TAG}
# docker tag ballaerospace/cosmosc2-base:${COSMOS_TAG} localhost:5151/cosmosc2-base:${COSMOS_TAG}
# docker push localhost:5151/cosmosc2-base:${COSMOS_TAG}

docker buildx bake --set *.platform=linux/arm64 --load --no-cache -f compose.yaml -f compose-build.yaml --progress=plain cosmos-node
docker push ${COSMOS_REGISTRY}/ballaerospace/cosmosc2-node:${COSMOS_TAG}
# docker tag ballaerospace/cosmosc2-node:${COSMOS_TAG} localhost:5151/cosmosc2-node:${COSMOS_TAG}
# docker push localhost:5151/cosmosc2-node:${COSMOS_TAG}

docker buildx bake --set *.platform=linux/arm64 --load --no-cache -f compose.yaml -f compose-build.yaml --progress=plain \
    cosmos-minio \
    cosmos-redis \
    cosmos-cmd-tlm-api \
    cosmos-script-runner-api \
    cosmos-operator \
    cosmos-traefik \
    cosmos-init