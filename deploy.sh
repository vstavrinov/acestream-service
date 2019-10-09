#!/usr/bin/env bash

if [ "$TRAVIS_TAG" = "" ]; then
    docker tag $DOCKER_USERNAME/$REPO registry.heroku.com/$REPO/web &&
    echo $HEROKU_API_KEY |
    docker login -u $HEROKU_IDENTITY --password-stdin registry.heroku.com &&
    docker push registry.heroku.com/$REPO/web &&
    curl -n -X PATCH https://api.heroku.com/apps/$REPO/formation \
      -d '{
      "updates": [
        {
          "type": "web",
          "docker_image": "'$(docker inspect $DOCKER_USERNAME/$REPO --format={{.Id}})'"
        }
      ]
    }' \
      -H "Content-Type: application/json" \                                                                               -H "Accept: application/vnd.heroku+json; version=3.docker-releases" \                                               -H "Authorization: $(echo -n $HEROKU_IDENTITY:$HEROKU_API_KEY | base64)"                                      else                                                                                                                    echo $DOCKER_PASSWORD |                                                                                             docker login -u $DOCKER_USERNAME --password-stdin &&                                                                docker push $DOCKER_USERNAME/$REPO
fi
