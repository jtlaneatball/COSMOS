#!/usr/bin/env sh

set -e

# This script is meant to be run on the target machine to load all of the docker images for cosmos 5

docker load -i cosmos-ruby.docker
docker load -i cosmos-base.docker
docker load -i cosmos-node.docker
docker load -i cosmos-cmd-tlm-api.docker
docker load -i cosmos-minio-init.docker
docker load -i cosmos-init.docker
docker load -i cosmos-operator.docker
docker load -i cosmos-redis.docker
docker load -i cosmos-script-runner-api.docker
docker load -i cosmos-traefik.docker

docker load -i minio.docker

# run "docker-compose -f compose.yaml up -d" to start cosmos 5