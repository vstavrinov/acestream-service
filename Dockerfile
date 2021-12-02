FROM alpine
WORKDIR /srv/acestream
ENV COLUMNS=116
ADD search.py .
RUN apk update &&                                                                         \
    apk add                                                                               \
        python2 py2-setuptools net-tools curl py3-setuptools nginx gcompat sudo           \
        uwsgi-python3 py3-flask py3-lxml py3-pip py3-wheel git alpine-sdk;                \
    sed '/PACKAGER=/c\PACKAGER="Vladimir Stavrinov <vstavrinov@gmail.com>"'               \
        -i /etc/abuild.conf;                                                              \
    git clone --depth 1 --branch v$(awk -F= '/VERSION_ID/ {print $2}' /etc/os-release)    \
        git://git.alpinelinux.org/aports /srv/aports;                                     \
    abuild-keygen -ani;                                                                   \
    cd /srv/aports/main/openssl;                                                          \
    sed -e 's/no-ec2m//' -e 's/^pkgrel=.*/&0/' -i APKBUILD;                               \
    abuild -F checksum; abuild -P /srv/packages -Fr;                                      \
    apk add /srv/packages/main/x86_64/libcrypto1.1-*.apk;                                 \
    rm /srv/packages/main/x86_64/APKINDEX.tar.gz;                                         \
    cp -a /srv/aports/testing/py3-apsw /srv/aports/main/py2-apsw;                         \
    cd /srv/aports/main/py2-apsw;                                                         \
    sed -e 's/py3/py2/' -e 's/python3/python2/' -e 's/^pkgrel=.*/&0/' -i APKBUILD;        \
    abuild -F checksum; abuild -P /srv/packages -Fr;                                      \
    apk add -uX /srv/packages/main py2-apsw; cd /srv/acestream;                           \
    curl http://acestream.org/downloads/linux/acestream_3.1.49_debian_9.9_x86_64.tar.gz | \
    tar xzf -;                                                                            \
    pip3 install git+https://github.com/vstavrinov/acestream_search.git;                  \
    apk del py3-pip py3-wheel git alpine-sdk net-tools curl py3-setuptools sudo;          \
    rm -fr /root/.cache /var/cache/apk/*; rm -fr /srv/packages /srv/aports;               \
    ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime;                              \
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
