#!/bin/bash -e

# Deploy to docker hub new version (tag)
TAG=$(versioningit)
echo Deploy to docker hub new version GITHUB_REF=${GITHUB_REF}, TAG=$TAG,  GITHUB_REF_NAME=$GITHUB_REF_NAME
docker tag $DOCKER_USERNAME/$DOCKER_REPO $DOCKER_USERNAME/$DOCKER_REPO:$TAG
docker tag $DOCKER_USERNAME/$DOCKER_REPO $DOCKER_USERNAME/$DOCKER_REPO:latest
echo $DOCKER_PASSWORD |
docker login -u $DOCKER_USERNAME --password-stdin
docker push $DOCKER_USERNAME/$DOCKER_REPO:$TAG
docker push $DOCKER_USERNAME/$DOCKER_REPO:latest
echo $GITHUB_PASSWORD |
docker login -u $GITHUB_USERNAME --password-stdin $GITHUB_REGISTRY
docker tag $DOCKER_USERNAME/$DOCKER_REPO $GITHUB_REGISTRY/$IMAGE_NAME:$TAG
docker tag $DOCKER_USERNAME/$DOCKER_REPO $GITHUB_REGISTRY/$IMAGE_NAME:latest
docker push $GITHUB_REGISTRY/$IMAGE_NAME:$TAG
docker push $GITHUB_REGISTRY/$IMAGE_NAME:latest
