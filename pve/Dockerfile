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
  apt update && apt install -y logrotate neovim netcat-openbsd sudo openssh-server wget systemctl curl gnupg ca-certificates rsyslog net-tools iputils-ping && \
  echo "**** setup openssh environment ****" && \
  useradd -m rander && \
  usermod --shell /bin/bash rander && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

## proxmox
#Add the Proxmox VE repository:
RUN wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg && \
    echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-free.list

RUN apt-get update && \
    apt-get install initramfs-tools && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    echo '#!/bin/bash' > /usr/sbin/update-initramfs && \
    echo 'exit 0' >> /usr/sbin/update-initramfs && \
    chmod +x /usr/sbin/update-initramfs

RUN apt-get update && \
    apt-get install $(apt-cache depends proxmox-ve|awk '{print $2}'|while read x;do apt-cache depends $x 2>/dev/null|grep Depends|awk '{print $2}'|grep ^[[:alnum:]];done|sort|uniq|egrep -v "pve|proxmox|ifenslave|ifupdown2|qemu-server"|xargs) && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# repacked proxmox-ve & pve-manager
RUN apt-get update && \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get install proxmox-ve || echo ok && \
    PVE_PKG="pve-manager" && \
    PVE_VER="$(ls /var/cache/apt/archives/${PVE_PKG}_*.deb|awk -F_ '{print $2}')" && \
    PVE_DEB1="${PVE_PKG}_${PVE_VER}_amd64.deb" && \
    mkdir /tmp/${PVE_PKG} && \
    dpkg -X /var/cache/apt/archives/${PVE_PKG}_${PVE_VER}_amd64.deb /tmp/${PVE_PKG}/ && \
    dpkg -e /var/cache/apt/archives/${PVE_PKG}_${PVE_VER}_amd64.deb /tmp/${PVE_PKG}/DEBIAN && \
    sed -i "s/ifupdown2 (>= 2.0.1-1+pve8) | ifenslave (>= 2.6),//g" /tmp/${PVE_PKG}/DEBIAN/control && \
    sed -i "s/ifupdown2 (>= 3.0) | ifenslave (>= 2.6),//g" /tmp/${PVE_PKG}/DEBIAN/control && \
    dpkg-deb -Zxz  -b /tmp/${PVE_PKG}/ /tmp && \
    PVE_PKG="proxmox-ve" && \
    PVE_VER="$(ls /var/cache/apt/archives/${PVE_PKG}_*.deb|awk -F_ '{print $2}')" && \
    PVE_DEB2="${PVE_PKG}_${PVE_VER}_all.deb" && \
    mkdir /tmp/${PVE_PKG} && \
    dpkg -X /var/cache/apt/archives/${PVE_PKG}_${PVE_VER}_all.deb /tmp/${PVE_PKG}/ && \
    dpkg -e /var/cache/apt/archives/${PVE_PKG}_${PVE_VER}_all.deb /tmp/${PVE_PKG}/DEBIAN && \
    sed -i "s/pve-kernel-helper,//g" /tmp/${PVE_PKG}/DEBIAN/control && \
    sed -i "s/pve-kernel-5.15,//g" /tmp/${PVE_PKG}/DEBIAN/control && \
    sed -i "s/proxmox-default-kernel, //g" /tmp/${PVE_PKG}/DEBIAN/control && \
    dpkg-deb -Zxz  -b /tmp/${PVE_PKG}/ /tmp && \
    dpkg -i /tmp/${PVE_DEB1} && \
    dpkg -i /tmp/${PVE_DEB2} && \
    echo '#!/bin/sh' > /etc/kernel/postrm.d/zz-proxmox-boot && \
    echo 'exit 0' >> /etc/kernel/postrm.d/zz-proxmox-boot && \
    apt-mark hold proxmox-ve && \
    apt-mark hold pve-manager && \
    rm -f /etc/apt/apt.conf.d/*pve* /etc/kernel/postinst.d/* && \
    echo '#!/bin/sh' > /var/lib/dpkg/info/ifupdown2.postinst && \
    echo 'exit 0' >> /var/lib/dpkg/info/ifupdown2.postinst && \
    apt-get -f install && \
    apt-get autoremove --purge && \
    apt-get purge ifupdown2 && \
    apt-get install proxmox-backup-restore-image && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    rm -f /etc/apt/sources.list.d/pve-enterprise.list

#set (temporary) password for root
RUN echo "root:root"|chpasswd

RUN systemctl enable pvenetcommit.service pve-firewall 


# add local files
EXPOSE 2222
EXPOSE 8006

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

RUN mkdir -p /run/ssh systemctl enable ssh 

#use setup.sh to start proxmox service
STOPSIGNAL SIGINT
ENTRYPOINT [ "/entrypoint.sh" ]
VOLUME /config
CMD [ "/lib/systemd/systemd", "log-level=info", "unit=sysinit.target"]
