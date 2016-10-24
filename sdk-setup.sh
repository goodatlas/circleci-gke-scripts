#!/bin/bash

set -e

while [[ $# -gt 1 ]]
do
    key="$1"

    case $key in
        -p|--project)
            GCLOUD_PROJECT_NAME="$2"
            shift
            ;;

        -c|--cluster)
            GCLOUD_CLUSTER_NAME="$2"
            shift
            ;;

        -z|--zone)
            GCLOUD_COMPUTE_ZONE="$2"
            shift
            ;;
        *)
            # unknown option
        ;;

    esac
    shift
done

if [ -z "$GCLOUD_PROJECT_NAME" ]; then echo "--project option is not specified"; exit 1; fi
if [ -z "$GCLOUD_CLUSTER_NAME" ]; then echo "--cluster option is not specified"; exit 1; fi
if [ -z "$GCLOUD_COMPUTE_ZONE" ]; then echo "--zone option is not specified"; exit 1; fi

echo "Setting up google cloud sdk..."
echo ${GCLOUD_SERVICE_KEY} | base64 --decode -i > ${HOME}/account-auth.json
sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update
sudo /opt/google-cloud-sdk/bin/gcloud --quiet components update kubectl
sudo /opt/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file ${HOME}/account-auth.json
sudo /opt/google-cloud-sdk/bin/gcloud config set project ${GCLOUD_PROJECT_NAME}
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set container/cluster ${GCLOUD_CLUSTER_NAME}
sudo /opt/google-cloud-sdk/bin/gcloud config set compute/zone ${GCLOUD_COMPUTE_ZONE}
sudo /opt/google-cloud-sdk/bin/gcloud config set container/use_client_certificate True
sudo /opt/google-cloud-sdk/bin/gcloud --quiet container clusters get-credentials ${GCLOUD_CLUSTER_NAME}
sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube