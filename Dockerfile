FROM nginx
WORKDIR /srv/acestream
ADD acestream /opt/acestream
COPY proxy.conf /etc/nginx/conf.d
RUN apt-get update && \
    apt-get install -y --no-install-recommends libpython2.7 python-pkg-resources net-tools python-apsw net-tools
CMD /opt/acestream/acestreamengine --client-console --log-file /var/log/acestream.log & \
    nginx -g "daemon off;"
