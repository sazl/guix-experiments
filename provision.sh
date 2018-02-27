#!/bin/bash -x

export PLATFORM=x86_64-linux
export VERSION=0.14.0
export BINARY="guix-binary-${VERSION}.${PLATFORM}.tar.xz"
export PACKAGE_URL="https://alpha.gnu.org/gnu/guix/${BINARY}"
export GUIX_PROFILE_PATH="${HOME}/.guix-profile"
export GUIX_BIN_PATH="${GUIX_PROFILE_PATH}/bin"
export GUIX_SYSTEMD_SERVICE="${GUIX_PROFILE_PATH}/lib/systemd/system/guix-daemon.service"
export GUIX="${GUIX_BIN_PATH}/guix"

apt-get update && apt-get upgrade -y &&\
cd / &&\
wget "${PACKAGE_URL}" &&\

(
    cat << EOF >> ~/.bashrc
export PATH=~/.guix-profile/bin:\$PATH
export GUIX_PROFILE="${GUIX_PROFILE_PATH}"
export GUIX_LOCPATH="\$GUIX_PROFILE/lib/locale"
source "\$GUIX_PROFILE/etc/profile"
EOF
) &&\

tar -C / --xz -xvf "${BINARY}" &&\

builders=10
groupadd guixbuild &&\
(
    for i in `seq 1 $builders`; do
        useradd \
            -g guixbuild \
            -G guixbuild \
            -d /var/empty \
            -s `which nologin` \
            -c "Guix build user $i" \
            --system "guix-builder$i";
    done
) &&\
chgrp guixbuild -R /gnu/store &&\

ln -sf /var/guix/profiles/per-user/root/guix-profile "${GUIX_PROFILE_PATH}" &&\
cp "${GUIX_SYSTEMD_SERVICE}" /etc/systemd/system/ &&\
systemctl enable guix-daemon.service &&\
systemctl start guix-daemon.service &&\
${GUIX} archive --authorize < "${GUIX_PROFILE_PATH}/share/guix/hydra.gnu.org.pub" &&\
${GUIX} pull &&\
${GUIX} package -u &&\
${GUIX} package -i glibc-locales
