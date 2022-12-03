#!/bin/bash -e

# Deploy to heroku and Cloud Function on commits of master branch 
# Deploy to docker hub new version (tag)
echo Deploy to docker hub new version GITHUB_REF=${GITHUB_REF}, TAG=$TAG,  GITHUB_REF_NAME=$GITHUB_REF_NAME
TAG=$(versioningit)
docker tag $DOCKER_USERNAME/$DOCKER_REPO $DOCKER_USERNAME/$DOCKER_REPO:$TAG
docker tag $DOCKER_USERNAME/$DOCKER_REPO $DOCKER_USERNAME/$DOCKER_REPO:latest
echo $DOCKER_PASSWORD |
docker login -u $DOCKER_USERNAME --password-stdin
docker push $DOCKER_USERNAME/$DOCKER_REPO:$TAG
docker push $DOCKER_USERNAME/$DOCKER_REPO:latest
