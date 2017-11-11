FROM debian:stretch-slim

ARG VERSION

ENV DEBIAN_FRONTEND=noninteractive

# jre installation script expects this dir to be present
RUN mkdir -p /usr/share/man/man1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    psmisc lsb-release sudo procps libcap2-bin curl \
    mongodb-server jsvc openjdk-8-jre-headless \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://dl.ubnt.com/firmwares/ufv/v${VERSION}/unifi-video.Debian7_amd64.v${VERSION}.deb -o /unifi-video.deb \
    && dpkg -i /unifi-video.deb \
    && rm /unifi-video.deb

RUN ln -sfn /unifi-video/logs /usr/lib/unifi-video/logs
RUN ln -sfn /unifi-video/data /usr/lib/unifi-video/data

COPY docker-entrypoint.sh /
COPY docker-healthcheck.sh /

VOLUME /unifi-video/data /unifi-video/logs
EXPOSE 7442 7443 7445 7446 7447 7080 6666

HEALTHCHECK CMD /docker-healthcheck.sh || exit 1
CMD [ "/docker-entrypoint.sh" ]
