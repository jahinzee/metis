#!/bin/bash

set -ouex pipefail

## -------------------------------------------------------------------------------------------------
##    Branding
## -------------------------------------------------------------------------------------------------

# This section adapted from:
#    https://github.com/winblues/blue95/blob/main/files/scripts/00-image-info.sh
# Authors:
#    jahinzee, ledif
# Changes: added metis branding, custom hostname, and generic logos

IMAGE_VENDOR="jahinzee"
IMAGE_NAME="metis"
IMAGE_PRETTY_NAME="Metis"
IMAGE_LIKE="fedora"
HOME_URL="https://github.com/jahinzee/metis"
DOCUMENTATION_URL="https://github.com/jahinzee/metis/blob/main/README.md"
SUPPORT_URL="https://github.com/jahinzee/metis/issues"
BUG_SUPPORT_URL="https://github.com/jahinzee/metis/issues"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"

FEDORA_MAJOR_VERSION=$(awk -F= '/VERSION_ID/ {print $2}' /etc/os-release)
BASE_IMAGE_NAME="Kinoite $FEDORA_MAJOR_VERSION"
BASE_IMAGE="ghcr.io/ublue-os/kinoite-main"

DEFAULT_HOSTNAME="localhost"

cat >$IMAGE_INFO <<EOF
{
  "image-name": "$IMAGE_NAME",
  "image-vendor": "$IMAGE_VENDOR",
  "image-ref": "$IMAGE_REF",
  "image-tag":"latest",
  "base-image-name": "$BASE_IMAGE",
  "fedora-version": "$FEDORA_MAJOR_VERSION"
}
EOF

# OS Release File
sed -i \
  "s/^VARIANT_ID=.*/VARIANT_ID=$IMAGE_NAME/" \
  /usr/lib/os-release
sed -i \
  "s/^PRETTY_NAME=.*/PRETTY_NAME=\"${IMAGE_PRETTY_NAME} (FROM Fedora ${BASE_IMAGE_NAME^})\"/" \
  /usr/lib/os-release
sed -i \
  "s/^NAME=.*/NAME=\"$IMAGE_PRETTY_NAME\"/" \
  /usr/lib/os-release
sed -i \
  "s/^ID=.*/ID=\"$IMAGE_NAME\"/" \
  /usr/lib/os-release
sed -i \
  "s|^HOME_URL=.*|HOME_URL=\"$HOME_URL\"|" \
  /usr/lib/os-release
sed -i \
  "s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"$DOCUMENTATION_URL\"|" \
  /usr/lib/os-release
sed -i \
  "s|^SUPPORT_URL=.*|SUPPORT_URL=\"$SUPPORT_URL\"|" \
  /usr/lib/os-release
sed -i \
  "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"$BUG_SUPPORT_URL\"|" \
  /usr/lib/os-release
sed -i \
  "s|^CPE_NAME=\"cpe:/o:fedoraproject:fedora|CPE_NAME=\"cpe:/o:winblues:${IMAGE_PRETTY_NAME,}|" \
  /usr/lib/os-release
sed -i \
  "s/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME=\"${DEFAULT_HOSTNAME,}\"/" \
  /usr/lib/os-release
sed -i \
  "s/^ID=fedora/ID=${IMAGE_PRETTY_NAME,}\nID_LIKE=\"${IMAGE_LIKE}\"/" \
  /usr/lib/os-release

# Add ID_LIKE tag to allow external apps to properly identify that this is based on Fedora Atomic
echo "ID_LIKE=\"${IMAGE_LIKE}\"" >> /usr/lib/os-release

# Fix issues caused by ID no longer being fedora
sed -i \
  "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" \
  /usr/sbin/grub2-switch-to-blscfg

# Switch to generic logos, because why not
dnf swap fedora-logos generic-logos -y

## -------------------------------------------------------------------------------------------------
##    Packages
## -------------------------------------------------------------------------------------------------

install() {
  echo "[install] $@"
  dnf5 install -y "$@"
}

install-from-copr() {
  echo "[install] (copr:$1) $2"
  dnf5 copr enable "$1" -y
  dnf5 install "$2" -y
  dnf5 copr disable "$1" -y
}

enable-service() {
  echo "[service] $1"
  systemctl enable "$1.service"
}


# pkg: KDE Utilities
install kclock \
        yakuake \
        kclock \
        kcolorchooser \
        yakuake \
        kolourpaint \
        haruna \
        elisa \
        gwenview \
        kalk \
        krdc \
        okular \
        plasma-browser-integration

# pkg: shell and some cli utils
install fish \
        helix \
        neovim \
        bat \
        btop \
        zoxide \
        ripgrep \
        fd \
        fastfetch \
        qalculate \
        merkuro

# pkg: pipx
install pipx

# copr-pkg: eza
# TODO: drop the copr repo and install from main repos when F42 has it back in stock.
#       <https://github.com/eza-community/eza/blob/main/INSTALL.md#fedora>
install-from-copr dturner/eza \
                  eza

# copr-pkg: topgrade
install-from-copr lilay/topgrade \
                  topgrade

# pkg: libvirt
install @virtualization

# pkg: Japanese IME
install fcitx5-mozc

# copr-pkg: Bengali IME
install-from-copr badshah/openbangla-keyboard \
                  fcitx-openbangla

# pkg: thunderbird
# I find the native package to be more reliable than the Flatpak version.
install thunderbird

# pkg: Homebrew support packages
# Since Homebrew is a user-level tool, integrating it on the system layer doesn't make a lot of
# sense, but installing the dependencies is fine.
install @development-tools \
        procps-ng \
        curl \
        file

# pkg: syncthing
install syncthing

# pkg: Brother printer drivers
install printer-driver-brlaser

# copr-pkg: ghostty
install-from-copr scottames/ghostty \
                  ghostty

# copr-pkg: KDE-Rounded-Corners
install-from-copr matinlotfali/KDE-Rounded-Corners \
                  kwin-effect-roundcorners

# ext-pkg: Librewolf (extern repo)
curl -fsSL https://repo.librewolf.net/librewolf.repo | tee /etc/yum.repos.d/librewolf.repo
install librewolf

# Setup native messaging host for Plasma integration.
mkdir -p /usr/lib/librewolf/
ln -s /usr/lib64/mozilla/native-messaging-hosts /usr/lib64/librewolf/native-messaging-hosts
ln -s /usr/lib/mozilla/native-messaging-hosts /usr/lib/librewolf/native-messaging-hosts