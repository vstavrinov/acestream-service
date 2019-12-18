#!/usr/bin/env bash

# Deploy to heroku and Cloud Function on commits of master branch 
echo Deploy to heroku
echo "
acestream $ACESTREAM_IDENTITY $ACESTREAM_API_KEY
cak $CAK_IDENTITY $CAK_API_KEY
buf $BUF_IDENTITY $BOV_API_KEY
" |
while read HEROKU_REPO HEROKU_IDENTITY HEROKU_API_KEY; do
    if [ -n "$HEROKU_REPO" ]; then
        echo $HEROKU_REPO $HEROKU_IDENTITY $HEROKU_API_KEY
        docker tag $DOCKER_USERNAME/$DOCKER_REPO registry.heroku.com/$HEROKU_REPO/web &&
        echo $HEROKU_API_KEY |
        docker login -u $HEROKU_IDENTITY --password-stdin registry.heroku.com &&
        docker push registry.heroku.com/$HEROKU_REPO/web &&
        curl -n -X PATCH https://api.heroku.com/apps/$HEROKU_REPO/formation \
         -d '{
          "updates": [
            {
              "type": "web",
              "docker_image": "'$(docker inspect registry.heroku.com/$HEROKU_REPO/web --format={{.Id}})'"
            }
          ]
        }' \
        -H "Content-Type: application/json" \
        -H "Accept: application/vnd.heroku+json; version=3.docker-releases" \
        -H "Authorization: $(echo -n $HEROKU_IDENTITY:$HEROKU_API_KEY | base64 -w0)"
    fi
done
# Deploy to docker hub new version (tag)
echo Deploy to docker hub
docker tag $DOCKER_USERNAME/$DOCKER_REPO $DOCKER_USERNAME/$DOCKER_REPO:${TRAVIS_TAG:=latest} &&
echo $DOCKER_PASSWORD |
docker login -u $DOCKER_USERNAME --password-stdin &&
docker push $DOCKER_USERNAME/$DOCKER_REPO
