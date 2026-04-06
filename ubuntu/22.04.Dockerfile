FROM ubuntu:22.04

LABEL maintainer="Melih Savdert"

ENV container=docker \
  DEBIAN_FRONTEND=noninteractive

RUN INSTALL_PKGS='findutils iproute2 python3 python3-apt sudo systemd' \
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
