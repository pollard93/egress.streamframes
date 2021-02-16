FROM debian:jessie

WORKDIR /tmp

RUN apt-get -y update
RUN apt-get -y install curl build-essential libpcre3 libpcre3-dev zlib1g-dev libssl-dev git gettext-base && \
    curl -LO http://nginx.org/download/nginx-1.9.3.tar.gz && \
    tar zxf nginx-1.9.3.tar.gz && \
    cd nginx-1.9.3 && \
    git clone -b AuthV2 https://github.com/anomalizer/ngx_aws_auth.git && \
    ./configure \
        --with-http_ssl_module \
        --with-http_secure_link_module \
        --add-module=ngx_aws_auth && \
    make install && \
    cd /tmp && \
    rm -f nginx-1.9.3.tar.gz && \
    rm -rf nginx-1.9.3 && \
    apt-get purge -y curl git && \
    apt-get autoremove -y

RUN mkdir -p /data/cache

EXPOSE 8080

COPY ./nginx.conf /nginx.conf.template

CMD envsubst "$(env | sed -e 's/=.*//' -e 's/^/\$/g')" < \
  /nginx.conf.template > /nginx.conf && \
  /usr/local/nginx/sbin/nginx -c /nginx.conf