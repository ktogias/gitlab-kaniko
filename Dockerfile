FROM golang:1.12
WORKDIR /go/src/github.com/GoogleContainerTools
RUN \
  git clone --branch v0.10.0 https://github.com/GoogleContainerTools/kaniko && \
  cd kaniko && \
  make GOARCH=amd64

# ------------------------------------------------------------------------------

FROM alpine:3.10
RUN \
  apk add --no-cache bash curl git && \
  mkdir -p /busybox-integration && \
  mkdir -p /busybox-integration/bin && \
  mkdir -p /busybox-integration/lib && \
  ls -al /bin && \
  ln -s /alpine/bin/busybox /busybox-integration/bin/ && \
  ln -s /alpine/bin/sh /busybox-integration/bin/ && \
  ln -s /alpine/bin/bash /busybox-integration/bin/ && \
  ln -s /alpine/lib/ld-musl-x86_64.so.1 /busybox-integration/lib/ && \
  ls -al /busybox-integration && \
  ls -al /busybox-integration/bin && \
  ls -al /busybox-integration/lib

# ------------------------------------------------------------------------------

FROM scratch
COPY --from=0 /go/src/github.com/GoogleContainerTools/kaniko/out/executor /kaniko/executor
COPY --from=0 /go/src/github.com/GoogleContainerTools/kaniko/files/ca-certificates.crt /kaniko/ssl/certs/
COPY --from=1 /busybox-integration /
COPY --from=1 / /alpine/
COPY target /alpine/

VOLUME /alpine

ENV HOME /root
ENV USER /root
ENV LD_LIBRARY_PATH /alpine/lib:/alpine/usr/lib
ENV PATH /kaniko:/alpine/usr/bin:/alpine/usr/sbin:/alpine/usr/local/bin:/alpine/usr/local/sbin:/alpine/bin:/alpine/sbin
ENV SSL_CERT_DIR=/kaniko/ssl/certs
ENV DOCKER_CONFIG /kaniko/.docker/

RUN \
  mkdir -p /kaniko/.docker && \
  rm -rf /alpine/busybox-integration
