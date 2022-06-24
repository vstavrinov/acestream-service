FROM vstavrinov/acestream-engine
WORKDIR /srv/acestream
ENV COLUMNS=116
ADD search.py .
RUN apk update &&                                                           \
    apk add                                                                 \
        nginx uwsgi-python3 py3-flask py3-lxml                              \
        py3-setuptools py3-pip py3-wheel git;                               \
    pip3 install git+https://github.com/vstavrinov/acestream_search.git;    \
    apk del py3-setuptools py3-pip py3-wheel git;                           \
    rm -fr /root/.cache /var/cache/apk/*; rm -fr /srv/packages /srv/aports; \
    ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime;                \
    chown -R nginx . /etc/nginx /var/lib/nginx
COPY default.conf /etc/nginx/http.d
USER nginx
CMD sed -e "s/PORT/${PORT:=80}/"                \
        -e "s/ENTRY/${ENTRY:+:$ENTRY}/"         \
        -e "s/SCHEME/${SCHEME:=https}/"         \
        -i /etc/nginx/http.d/default.conf;      \
    sed -e "/^user /"d                          \
        -e "/^pid /s%/var/run/%%"               \
        -i /etc/nginx/nginx.conf;               \
    HOME=. ./acestreamengine --client-console & \
    uwsgi --plugin python,http                  \
          --http-socket 127.0.0.1:3031          \
          --uid nginx                           \
          --wsgi-file search.py                 \
          --callable app                        \
          --workers 4                           \
          --threads 4                           \
          --master &                            \
    nginx -g "daemon off;"
