#!/bin/bash

# Exit if anything fails
set -e

DOCKER_RUN_REPO="lh-orcl"
DOCKER_RUN_IMAGE="docker-nagios_test"
DOCKER_NAG_NET="client-net"

docker build -t	$DOCKER_RUN_REPO/$DOCKER_RUN_IMAGE:latest .

docker images
docker run -di --name "$DOCKER_RUN_IMAGE" -p 80:80 -t "$DOCKER_RUN_REPO/$DOCKER_RUN_IMAGE"
docker network connect $DOCKER_NAG_NET $DOCKER_RUN_IMAGE
docker ps -a
