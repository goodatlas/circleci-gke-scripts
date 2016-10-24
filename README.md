# Circle CI / Google Container Engine scripts
Helper scripts for continuous deployment with Circle CI and Google Container Engine

## Example

#### my-app-deployment.yml

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: my-node-app-deployment
spec:
  template:
    metadata:
      labels:
        app: my-node-app
    spec:
      containers:
        - image: gcr.io/gcloud-project-123456/my-node-app:latest
          name: my-node-app
```

#### circle.yml

```
machine:
  node:
    version: 6.7.0
  environment:
    GCLOUD_PROJECT_NAME: gcloud-project-123456
    GCLOUD_CLUSTER_NAME: my-cluster
    GCLOUD_COMPUTE_ZONE: us-central1-b
    DOCKER_IMAGE_NAME: gcr.io/gcloud-project-123456/my-node-app
    DEBIAN_FRONTEND: noninteractive
  services:
    - docker

dependencies:
  override:
    - wget -i https://raw.githubusercontent.com/diorman/circleci-gke-scripts/master/scripts.txt -P ${HOME}/scripts
    - chmod a+x ${HOME}/scripts/*.sh
    - npm install

test:
  override:
    - npm test

deployment:
  prod:
    branch: master
    commands:
      - ${HOME}/scripts/sdk-setup.sh
      - ${HOME}/scripts/gcr-upload.sh
      - ${HOME}/scripts/k8s-deploy.sh my-node-app-deployment -c my-node-app
```

## Scripts

### <span>sdk-setup</span>.sh

Configures Google Cloud SDK.

```
$ ./sdk-setup.sh [OPTIONS]
```

Options:

  * -p | --project - Google cloud project. Default `$GCLOUD_PROJECT_NAME`
  * -c | --cluster - Google cloud cluster. Default `$GCLOUD_CLUSTER_NAME`
  * -z | --zone    - Google cloud compute zone. Default `$GCLOUD_COMPUTE_ZONE`

### <span>gcr-upload</span>.sh

Builds docker image and pushes it to Google Container Registry.

```
$ ./gcr-upload.sh [IMAGE_NAME]
```

Arguments:

* IMAGE_NAME - Name for the docker image to be created. Default `$DOCKER_IMAGE_NAME`

### <span>k8s-deploy</span>.sh

Updates image of a running container managed by a deployment.

```
$ ./k8s-deploy.sh DEPLOYMENT [OPTIONS]
```

Arguments:

* DEPLOYMENT - Name of the deployment.

Options:

* -c | --container - Name of the container. Default `DEPLOYMENT` name
* -i | --image - Name of the image. Default `$DOCKER_IMAGE_NAME`

## Notes
* You must define a new environment variable with the name `GCLOUD_SERVICE_KEY` and use the base64 encoded JSON key from Google as the value. Go here for more instructions [Circle CI Guide - Authentication with Google Cloud Platform](https://circleci.com/docs/google-auth)
* Resource: [Circle CI Guide - Continuous Deployment with Google Container Engine](https://circleci.com/docs/continuous-deployment-with-google-container-engine)