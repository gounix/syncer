ARG UBUNTU_VERSION=26.04
ARG SYNCER_VERSION

FROM docker.io/ubuntu:${UBUNTU_VERSION}
ARG SYNCER_VERSION

RUN apt-get install --update -y buildah ca-certificates 

COPY ./syncer.sh /
RUN sed -i s/Development-version/${SYNCER_VERSION}/ /syncer.sh

CMD [ "/syncer.sh" ]
