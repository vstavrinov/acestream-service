FROM vstavrinov/acestream-engine
WORKDIR /srv/ace
ENV COLUMNS=116
ENV PYTHONDONTWRITEBYTECODE=0
ENV TMP=/dev/shm/tmp
ADD search.py setup.cfg .
USER root
RUN apt-get update; apt-get --yes install nginx; apt-get clean;  \
    ln --symbolic --force /dev/stderr /var/log/nginx/error.log;  \
    ln --symbolic --force /dev/stdout /var/log/nginx/access.log; \
    ln --symbolic --force  /dev/shm/.ACEStream .ACEStream;       \
    rmdir --verbose /var/lib/nginx;                              \
    ln --symbolic --force /dev/shm/nginx/lib  /var/lib/nginx;    \
    pip install --no-cache-dir gunicorn flask                    \
        git+https://github.com/vstavrinov/acestream_search.git
COPY default.conf /etc/nginx/sites-available/default
COPY nginx.conf /etc/nginx/
USER ace
CMD mkdir --verbose /dev/shm/.ACEStream;                    \
    mkdir --verbose /dev/shm/tmp;                           \
    cp --verbose --archive /etc/nginx /dev/shm;             \
    mkdir --verbose /dev/shm/nginx/lib;                     \
    cd /dev/shm/nginx/sites-enabled;                        \
    ln --symbolic --force ../sites-available/default .; cd; \
    sed --expression="s/PORT/${PORT:=80}/"                  \
        --expression="s/ENTRY/${ENTRY:+:$ENTRY}/"           \
        --expression="s/SCHEME/${SCHEME:=https}/"           \
        --in-place /dev/shm/nginx/sites-available/default;  \
    gunicorn --bind 0.0.0.0:3031 search:app &               \
    /usr/sbin/nginx -c /dev/shm/nginx/nginx.conf &          \
    ./start-engine                                          \
        --client-console                                    \
        --live-cache-type memory
