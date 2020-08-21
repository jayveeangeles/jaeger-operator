FROM golang:1.14.7 as builder

COPY . /workdir

WORKDIR /workdir

RUN make GO_FLAGS="GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GO111MODULE=on" build

FROM centos

ENV OPERATOR=/usr/local/bin/jaeger-operator \
    USER_UID=1001 \
    USER_NAME=jaeger-operator

RUN INSTALL_PKGS=" \
      openssl \
      " && \
    yum install -y $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all && \
    mkdir /tmp/_working_dir && \
    chmod og+w /tmp/_working_dir

COPY scripts/* /scripts/

# install operator binary
COPY --from=builder /workdir/build/_output/bin/jaeger-operator ${OPERATOR}

COPY build/bin /usr/local/bin
RUN  /usr/local/bin/user_setup

ENTRYPOINT ["/usr/local/bin/entrypoint"]

USER ${USER_UID}

