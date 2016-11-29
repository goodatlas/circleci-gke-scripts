#!/bin/bash

set -e

run-gcr-upload() {
  local key
  local build_script=
  local docker_images=()
  local docker_image

  while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
      -f|--build-file)
        build_script="$2"
        shift
        ;;

      -i|--image)
        docker_images+=("$2")
        shift
        ;;
    esac
    shift
  done

  if [[ ${#docker_images[@]} -eq 0 && -n "$DOCKER_IMAGE_NAME" ]]; then
    docker_images+=("$DOCKER_IMAGE_NAME")
  elif [[ ${#docker_images[@]} -eq 0 && -z "$DOCKER_IMAGE_NAME" ]]; then
    echo "docker images not specified"
    exit 1
  fi

  if [[ -n "$build_script" ]]; then
    $build_script
  else
    for docker_image in "${docker_images[@]}"; do
      echo "Building docker image: $docker_image..."
      docker build -t ${docker_image}:${CIRCLE_SHA1} .
    done
  fi

  for docker_image in "${docker_images[@]}"; do
    echo "Pushing image $docker_image to registry..."
    sudo /opt/google-cloud-sdk/bin/gcloud docker -- push ${docker_image}
  done
}

run-gcr-upload "$@"
