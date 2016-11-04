#!/bin/bash

run-k8s-deploy() {
  local key
  local container
  local docker_image_name
  local kubernetes_namespace="default"

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
        kubernetes_namespace="$2"
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

  container="${$container:-$deployment}"

  kubectl rollout status deployment/${deployment} --namespace ${namespace} && \
    kubectl set image deployment/${deployment} ${container}=${docker_image_name}:${CIRCLE_SHA1} --namepace ${namespace}
}

run-k8s-deploy "$@"
