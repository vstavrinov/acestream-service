FROM nginx
WORKDIR /srv/acestream
COPY fortune /srv/cgi/cgi/
COPY index.shtml /srv/www/
ADD acestream /opt/acestream
COPY default.conf fortune.conf /etc/nginx/conf.d/
EXPOSE 6868/tcp
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpython2.7 python-pkg-resources net-tools python-apsw net-tools \
        fcgiwrap fortunes;
CMD /opt/acestream/acestreamengine --client-console --log-file /var/log/acestream.log & \
    /etc/init.d/fcgiwrap start; nginx -g "daemon off; user www-data;"
