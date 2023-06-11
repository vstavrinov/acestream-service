FROM vstavrinov/acestream-engine
WORKDIR /srv/ace
ENV COLUMNS=116
ADD search.py .
USER root
RUN apt-get update;                                          \
    apt-get --yes install nginx;                             \
    apt-get clean;                                           \
    ln -sf /dev/stderr /var/log/nginx/error.log;             \
    ln -sf /dev/stdout /var/log/nginx/access.log;            \
    chown -R ace . /etc/nginx /var/lib/nginx /var/log/nginx; \
    pip install --no-cache-dir gunicorn flask                \
        git+https://github.com/vstavrinov/acestream_search.git
COPY default.conf /etc/nginx/sites-available/default
USER ace
CMD sed -e "s/PORT/${PORT:=80}/"               \
        -e "s/ENTRY/${ENTRY:+:$ENTRY}/"        \
        -e "s/SCHEME/${SCHEME:=https}/"        \
        -i /etc/nginx/sites-available/default; \
    sed -e "/^user /"d                         \
        -e "/^pid /s%/run/%/srv/ace/%"         \
        -i /etc/nginx/nginx.conf;              \
    mkdir --verbose /dev/shm/.ACEStream;       \
    ln -v -s /dev/shm/.ACEStream .ACEStream;   \
    gunicorn --bind 0.0.0.0:3031 search:app &  \
    /usr/sbin/nginx &                          \
    ./start-engine                             \
        --client-console                       \
        --live-cache-type memory
