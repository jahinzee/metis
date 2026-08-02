FROM scratch AS ctx
COPY build /

FROM ghcr.io/ublue-os/kinoite-main:latest
# --mount=type=bind,from=ctx,source=/,target=/ctx/build.sh \
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    << EOF
set -ouex pipefail
dnf5 copr enable -y imput/helium
rm /opt && mkdir /opt
dnf5 install -y \
    distrobox \
    helium-bin \
    podman \
    nix \
    nix-daemon
dnf5 remove -y firefox
dnf5 copr disable -y imput/helium

cat << EOF2 > /usr/lib/systemd/system/nix.mount
[Unit]
Description=Bind mount /var/nix to /nix

[Mount]
What=/var/nix
Where=/nix
Type=none
Options=bind

[Install]
WantedBy=local-fs.target
EOF2

systemctl enable nix.mount
systemctl enable nix-daemon.service
EOF