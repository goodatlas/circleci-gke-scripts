#!/bin/bash

set -e

run-sdk-setup() {
  local key
  local gcloud_project_name="$GCLOUD_PROJECT_NAME"
  local gcloud_cluster_name="$GCLOUD_CLUSTER_NAME"
  local gcloud_compute_zone="$GCLOUD_COMPUTE_ZONE"

  while [[ $# -gt 1 ]]; do
    key="$1"

    case $key in
      -p|--project)
        gcloud_project_name="$2"
        shift
        ;;

      -c|--cluster)
        gcloud_cluster_name="$2"
        shift
        ;;

      -z|--zone)
        gcloud_compute_zone="$2"
        shift
        ;;
      esac
      shift
  done

  if [ -z "$gcloud_project_name" ]; then echo "--project option is not specified"; exit 1; fi
  if [ -z "$gcloud_cluster_name" ]; then echo "--cluster option is not specified"; exit 1; fi
  if [ -z "$gcloud_compute_zone" ]; then echo "--zone option is not specified"; exit 1; fi

  echo "Setting up google cloud sdk..."
  echo ${GCLOUD_SERVICE_KEY} | base64 --decode -i > ${HOME}/account-auth.json
  sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update
  sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update kubectl
  sudo /opt/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file ${HOME}/account-auth.json
  sudo /opt/google-cloud-sdk/bin/gcloud config set project ${gcloud_project_name}
  sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set container/cluster ${gcloud_cluster_name}
  sudo /opt/google-cloud-sdk/bin/gcloud config set compute/zone ${gcloud_compute_zone}
  sudo /opt/google-cloud-sdk/bin/gcloud config set container/use_client_certificate True
  sudo /opt/google-cloud-sdk/bin/gcloud --quiet container clusters get-credentials ${gcloud_cluster_name}
  sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube
}

run-sdk-setup "$@"
