#!/bin/bash

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -c|--container)
            CONTAINER="$2"
            shift
            ;;

        -i|--image)
            DOCKER_IMAGE_NAME="$2"
            shift
            ;;
        *)
            DEPLOYMENT="$key"
        ;;

    esac
    shift
done

if [ -z "$DEPLOYMENT" ]; then echo "deployment/container name is not specified"; exit 1; fi
if [ -z "$DOCKER_IMAGE_NAME" ]; then echo "docker image name is not specified"; exit 1; fi
[[ -z "$CONTAINER" ]] && CONTAINER="$DEPLOYMENT"

kubectl rollout status deployment/${DEPLOYMENT} && \
    kubectl set image deployment/${DEPLOYMENT} ${CONTAINER}=${DOCKER_IMAGE_NAME}:${CIRCLE_SHA1}