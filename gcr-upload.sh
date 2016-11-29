#!/bin/bash

set -e

run-gcr-upload() {
  local key
  local build_script=
  local docker_images=()
  local docker_image
  local docker_image_latest_tag
  local docker_image_tag

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

      -t|--tag)
        docker_image_tag="$2"
        shift
        ;;

      -lt|--latest-tag)
        docker_image_latest_tag="$2"
        shift
        ;;
    esac
    shift
  done

  if [[ ${#docker_images[@]} -eq 0 ]]; then
    echo "At least one docker image is required"
    exit 1
  fi

  if [[ -n "$build_script" ]]; then
    $build_script
  elif [[ -z "$docker_image_tag" || -z "$docker_image_latest_tag" ]]; then
    echo "Docker image tags are required"
    exit 1
  else
    for docker_image in "${docker_images[@]}"; do
      echo "Building docker image: ${docker_image}:${docker_image_tag}..."
      docker build -t ${docker_image}:${docker_image_tag} .
      docker tag ${docker_image}:${docker_image_tag} ${docker_image}:${docker_image_latest_tag}
    done
  fi

  for docker_image in "${docker_images[@]}"; do
    echo "Pushing image $docker_image to registry..."
    sudo /opt/google-cloud-sdk/bin/gcloud docker -- push ${docker_image}
  done
}

run-gcr-upload "$@"
