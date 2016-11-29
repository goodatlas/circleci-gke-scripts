#!/bin/bash

run-k8s-deploy() {
  local key
  local container
  local docker_tagged_image
  local namespace="default"

  while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
      -c|--container)
        container="$2"
        shift
        ;;

      -t|--tagged-image)
        docker_tagged_image="$2"
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

  if [ -z "$deployment" ]; then echo "deployment/container name is required"; exit 1; fi
  if [ -z "$docker_tagged_image" ]; then echo "--tag option is required"; exit 1; fi

  container="${container:-$deployment}"

  echo "Performing rolling update for deployment $deployment using image ${docker_tagged_image}"
  (kubectl rollout status deployment/${deployment} --namespace ${namespace} && \
    kubectl set image deployment/${deployment} --namespace ${namespace} ${container}=${docker_tagged_image}) || \
    echo "Warning: Ignoring rolling update"
}

run-k8s-deploy "$@"
