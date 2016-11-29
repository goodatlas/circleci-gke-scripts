#!/bin/bash

run-k8s-deploy() {
  local key
  local container
  local docker_image_name="$DOCKER_IMAGE_NAME"
  local namespace="default"

  while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
      -c|--container)
        container="$2"
        shift
        ;;

      -i|--image)
        docker_image_name="$2"
        shift
        ;;

      --namespace)
        namespace="$2"
        shift
        ;;

      *)
        deployment="$key"
        ;;
    esac
    shift
  done

  if [ -z "$deployment" ]; then echo "deployment/container name is not specified"; exit 1; fi
  if [ -z "$docker_image_name" ]; then echo "--image option is not specified"; exit 1; fi

  container="${container:-$deployment}"

  echo "Performing rolling update for deployment $deployment using image ${docker_image_name}:${CIRCLE_SHA1}"
  (kubectl rollout status deployment/${deployment} --namespace ${namespace} && \
    kubectl set image deployment/${deployment} --namespace ${namespace} ${container}=${docker_image_name}:${CIRCLE_SHA1}) || \
    echo "Warning: Ignoring rolling update"
}

run-k8s-deploy "$@"
