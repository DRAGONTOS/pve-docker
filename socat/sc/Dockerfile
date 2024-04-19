# syntax=docker/dockerfile:1
FROM quay.io/toolbx-images/debian-toolbox:12

ENV PVE_VERSION=8.1 \
    SERVICE=pve-docker \
    DEBIAN_FRONTEND=noninteractive

# set apt config
RUN echo 'APT::Get::Assume-Yes "1";' > /etc/apt/apt.conf.d/00-custom && \
    echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-custom && \
    echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-custom

RUN apt-get update && \
    apt-get dist-upgrade

RUN \
  echo "**** install runtime packages ****" && \
  apt update && apt install -y socat logrotate btop kitty-terminfo neovim netcat-openbsd sudo wget systemctl curl gnupg ca-certificates rsyslog net-tools iputils-ping && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

#set (temporary) password for root
RUN echo "root:root"|chpasswd

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

STOPSIGNAL SIGINT
ENTRYPOINT [ "/entrypoint.sh" ]
#CMD [ "/lib/systemd/systemd", "log-level=info", "unit=sysinit.target"]
