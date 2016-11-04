#!/bin/bash

set -e

run-gcr-upload() {
  local docker_image_name="${$1:-$DOCKER_IMAGE_NAME}"

  if [ -z "$docker_image_name" ]; then echo "docker image name is not specified"; exit 1; fi

  echo "Building docker image..."
  docker build -t ${docker_image_name}:${CIRCLE_SHA1} .
  docker tag ${docker_image_name}:${CIRCLE_SHA1} ${docker_image_name}:latest-${CIRCLE_BRANCH}

  echo "Pushing image to registry..."
  sudo /opt/google-cloud-sdk/bin/gcloud docker -- push ${docker_image_name}
}

run-gcr-upload "$@"
