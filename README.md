# acestream-service

acestream & search engines two in one in docker container turns it into iptv service provided both m3u playlist and live streams. First, asestream-docker is both streaming service and search engine all in one. There are examples of usage for both cases. As search engine it produces play playlist in response to search request, then You can feed this playlist to player to watch TV streaming from the same service, that is acestream-service. Second, in fact acestream-service and https://github.com/vstavrinov/acestream\_search both are built on top of acestream engine, or other words they are wrappers around it. But while asestream-docker already contains acestream engine inside, https://github.com/vstavrinov/acestream\_search requires You to install and run acestream engine in client mode. Look into Dockerfile to see how to do this, or visit it's home page.

## Build:

```
git clone https://github.com/vstavrinov/acestream-service.git
cd acestream-service
docker build -t acestream-service .
```

## Usage:

```
docker run -d -e PORT=<service-port> -e port=<host-port> -p <container-port>:<service-port> <acestream-image>
```

- service-port is port of service inside container.
- container-port is port listening by docker container  proxied to service-port
- host-port is either external port forwarded to docker-port or container-port itself exposed outside host.
- acestream-image is either docker image You build on your own or those pulled from repository.

host-port is used to rewrite standard acestream engine port 6868 in response to external port to make streams available from outside of container in case for example when docker container is running on the cloud. By default host-port is set to 80. If this is Your case, you can omit -e port=host-port option. But if make requests from the host running docker container, i.e. localhost,  You must set host equal to container-port.


For example:

```
docker run -d -e PORT=7000 -e port=8000 -p 8000:7000 acestream-service
```
Or you can omit build phase and pull and run it directly from repository:

```
docker run -d -e PORT=7000 -e port=8000 -p 8000:7000 docker vstavrinov/acestream-service
```

Finally you can watch tv:

```
vlc --playlist-autostart http://localhost:8000/search.m3u
```

This feeds long playlist to vlc You surf through to switch any channel.
You can use any player you prefer and domain where to run docker container.

See more available options:

```
curl http://localhost:8000/search.m3u?help
```

For example, CNN playlist:

```
curl http://localhost:8000/search.m3u?query=CNN
```

Or watch CNN separately:

```
vlc --playlist-autostart http://localhost:8000/search.m3u?query=CNN

