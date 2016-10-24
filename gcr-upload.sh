#!/bin/bash

set -e

[[ -n "$1" ]] && DOCKER_IMAGE_NAME="$1"

if [ -z "$DOCKER_IMAGE_NAME" ]; then echo "docker image name is not specified"; exit 1; fi

echo "Building docker image..."
docker build -t ${DOCKER_IMAGE_NAME}:${CIRCLE_SHA1} .
docker tag ${DOCKER_IMAGE_NAME}:${CIRCLE_SHA1} ${DOCKER_IMAGE_NAME}:latest-${CIRCLE_BRANCH}

echo "Pushing image to registry..."
sudo /opt/google-cloud-sdk/bin/gcloud docker -- push ${DOCKER_IMAGE_NAME}