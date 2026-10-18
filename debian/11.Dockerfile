FROM debian:bullseye

LABEL maintainer="Melih Savdert"

ENV container=docker \
    DEBIAN_FRONTEND=noninteractive

# Debian 11 is end of life: its repositories moved to archive.debian.org.
RUN printf '%s\n' \
    'deb http://archive.debian.org/debian bullseye main' \
    'deb http://archive.debian.org/debian-security bullseye-security main' \
    > /etc/apt/sources.list \
    && INSTALL_PKGS='findutils iproute2 python3 python3-apt sudo systemd' \
    && apt-get update \
    && apt-get install -y --no-install-recommends $INSTALL_PKGS \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -print0 | xargs -0 rm -vf

VOLUME ["/sys/fs/cgroup"]

ENTRYPOINT ["/lib/systemd/systemd"]