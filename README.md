# acestream-docker

acestream & search engines in docker container turns it into iptv service provided both m3u playlist and live streams.

## Usage:

```
docker run -d -e PORT=service-port -e port=host-port -p container-port:service-port acestream-image
```

- service-port is port of service inside container.
- host-port is either external port forwarded to docker-port or docker-port itself exposed outside host.
- acestream-image is either docker image You build on your own or those pulled from repository.


For example:

```
docker run -d -e PORT=7000 -e port=8000 -p 8000:7000 acestream
```

Finally you can watch tv:

```
vlc http://localhost:8000/search.m3u
```

You can use any player you prefer and  domain where to run docker container.
See available options:

```
curl http://localhost:8000/search.m3u?help
```
For example, CNN playlist:

```
curl http://localhost:8000/search.m3u?query=CNN
```

