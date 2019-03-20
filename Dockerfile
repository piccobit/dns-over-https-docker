##
# Stage 1 - Build dns-over-https binary
#

FROM golang:1.11 as builder

ENV DNSOVERHTTPS_VERSION=1.4.2

ADD https://github.com/m13253/dns-over-https/archive/v${DNSOVERHTTPS_VERSION}.tar.gz /tmp

RUN tar -xf /tmp/v${DNSOVERHTTPS_VERSION}.tar.gz -C /tmp \
    && cd /tmp/dns-over-https-${DNSOVERHTTPS_VERSION} \
    && make \
    && cp /tmp/dns-over-https-${DNSOVERHTTPS_VERSION}/doh-server/doh-server /usr/bin/doh-server \
    && cp /tmp/dns-over-https-${DNSOVERHTTPS_VERSION}/doh-client/doh-client /usr/bin/doh-client \
    && echo Build successful!


##
# Stage 2 - Docker image
#

# Use Alpine Linux as our base image so that we minimize the overall size our final container, and minimize the surface area of packages that could be out of date.
FROM alpine:3.8@sha256:621c2f39f8133acb8e64023a94dbdf0d5ca81896102b9e57c0dc184cadaf5528

LABEL description="Docker container for running your own DNS-over-HTTPS server."
LABEL maintainer="HD Stich <hd.stich.io>"

# ENV DNSOVERHTTPS_BINARY=stdiscosrv-linux-amd64-${DNSOVERHTTPS_VERSION}

RUN apk upgrade \
    && apk add --update libc6-compat libstdc++ \
    && apk add --no-cache ca-certificates

RUN addgroup -g 1000 dnsoverhttps \
    && adduser -D -G dnsoverhttps -u 1000 dnsoverhttps \
    && mkdir -p /etc/dns-over-https

COPY --from=builder /usr/bin/doh-server /usr/bin/doh-server
COPY --from=builder /usr/bin/doh-client /usr/bin/doh-client

VOLUME /etc/dns-over-https

EXPOSE 80

WORKDIR /

USER dnsoverhttps

CMD ["doh-server", "-conf", "/etc/dns-over-https/doh-server.conf", "-verbose"]
