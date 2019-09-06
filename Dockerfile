FROM python:2-slim
ADD acestream /opt/acestream
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpython2.7 python-pkg-resources net-tools python-apsw curl net-tools; \
    useradd -m -d /srv/acestream acestream
USER acestream
WORKDIR /srv/acestream
ENTRYPOINT /opt/acestream/acestreamengine --client-console --log-file acestream.log --http-port $PORT
