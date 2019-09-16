FROM nginx
WORKDIR /srv/acestream
ADD search.py .
COPY nginx.conf /etc/nginx
COPY default.conf /etc/nginx/conf.d
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpython2.7 python-pkg-resources net-tools python-apsw curl unzip fcgiwrap python-setuptools; \
    curl http://acestream.org/downloads/linux/acestream_3.1.49_debian_9.9_x86_64.tar.gz | \
    tar xzf -; \
    curl -kL https://github.com/vstavrinov/acestream_search/archive/master.zip > acestream_search.zip; \
    unzip acestream_search.zip; cd acestream_search-master; \
    python setup.py install; cd - ; usermod -d /srv/acestream www-data; \
    chown -R www-data ./ /etc/nginx /var/cache/nginx
USER www-data
CMD sed -i -e "s/PORT/$PORT/" -e "s/port/${port:=80}/" /etc/nginx/conf.d/default.conf; \
    ./acestreamengine --client-console & \
    fcgiwrap -s unix:./fcgiwrap.socket -p /srv/acestream/search.py -c 8 & \
    nginx -g "daemon off;"
