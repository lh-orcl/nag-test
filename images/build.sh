#!/bin/bash

DOCKER_RUN_REPO="lh-orcl"
DOCKER_RUN_IMAGE="docker-nagios_test"

docker build -t	$DOCKER_RUN_REPO/$DOCKER_RUN_IMAGE:latest .

docker images
docker run -d --name "$DOCKER_RUN_IMAGE" -p 80:80 -t "$DOCKER_RUN_REPO/$DOCKER_RUN_IMAGE"
docker ps -a
