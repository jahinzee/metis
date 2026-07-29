#!/bin/bash

# ================================================================================================
# FILE DEPRECATED -- replaced by /build/init.py
# ================================================================================================

# shellcheck disable=SC1091 source=.cleanup.sh
set -ouex pipefail

#  ··· Header
#      + boilerplate bash function definitions.
#
# region header

CLEANUP="$(mktemp -t cleanup.XXXXXXXX --suffix .sh)"
touch "$CLEANUP"
echo "#!/bin/bash" >> "$CLEANUP"
echo "set -ouex pipefail" >> "$CLEANUP"
chmod +x "$CLEANUP"
function defer { echo "$@" >> .cleanup.sh; }
function run-defer { . "$CLEANUP"; rm "$CLEANUP"; }

function get-fedora-release { awk -F= '/VERSION_ID/ {print $2}' /etc/os-release; }

function install { dnf5 install -y "$@"; }
function uninstall { dnf5 remove -y "$@"; }
function swap { dnf5 swap -y "$1" "$2"; }

function disable-copr { dnf5 copr disable -y "$1"; }
function enable-copr { dnf5 copr enable -y "$1"; }
function enable-copr-dd { enable-copr "$1"; defer disable-copr "$1"; }

function remove-repo { rm "/etc/yum.repos.d/$1.repo"; } 
function enable-repo { dnf5 config-manager addrepo -y --from-repofile="$1"; }
function enable-repo-dd { enable-repo "$1"; defer remove-repo "$1"; }
function enable-repo-from-url { enable-repo "$2/$1.repo"; }
function enable-repo-from-url-dd { enable-repo "$2/$1.repo"; defer remove-repo "$1"; }
function enable-obs-repo { enable-repo-from-url "$1" "https://download.opensuse.org/repositories/$1/Fedora_$(get-fedora-release)"; }
function enable-obs-repo-dd { enable-obs-repo "$1"; defer remove-repo "$1"; }

function sed-os-release { for arg in "$@"; do sed -i "$arg" /usr/lib/os-release; done; }

# endregion

#  ··· Branding
#      + apply custom Metis branding and generic logos.
#
# region branding

# Based on: https://github.com/winblues/blue95/blob/main/files/scripts/00-image-info.sh
# Authors: jahinzee, ledif
# Changes:
#   * added metis/Metis branding
#   * custom hostname
#   * added generic logos
#   * added ID_LIKE fixes
#   * refactored into bash functions

# region branding-vars

IMAGE_VENDOR="jahinzee"
IMAGE_NAME="metis"
IMAGE_PRETTY_NAME="Metis"
IMAGE_LIKE="fedora"
HOME_URL="https://github.com/$IMAGE_VENDOR/$IMAGE_NAME"
DOCUMENTATION_URL="$HOME_URL/blob/main/README.md"
SUPPORT_URL="$HOME_URL/issues"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/$IMAGE_VENDOR/$IMAGE_NAME"

FEDORA_MAJOR_VERSION=$(awk -F= '/VERSION_ID/ {print $2}' /etc/os-release)
BASE_IMAGE_NAME="Kinoite $FEDORA_MAJOR_VERSION"
BASE_IMAGE="ghcr.io/ublue-os/kinoite-main"

DEFAULT_HOSTNAME="localhost"

# endregion

# region branding-steps

# ››› Customise image-info.json file.
#
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

# Customise os-release file.
sed-os-release \
    "s/^VARIANT_ID=.*/VARIANT_ID=$IMAGE_NAME/" \
    "s/^PRETTY_NAME=.*/PRETTY_NAME=\"${IMAGE_PRETTY_NAME} (FROM Fedora ${BASE_IMAGE_NAME^})\"/" \
    "s/^NAME=.*/NAME=\"$IMAGE_PRETTY_NAME\"/" \
    "s/^ID=.*/ID=\"$IMAGE_NAME\"/" \
    "s|^HOME_URL=.*|HOME_URL=\"$HOME_URL\"|" \
    "s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"$DOCUMENTATION_URL\"|" \
    "s|^SUPPORT_URL=.*|SUPPORT_URL=\"$SUPPORT_URL\"|" \
    "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"$SUPPORT_URL\"|" \
    "s|^CPE_NAME=\"cpe:/o:fedoraproject:fedora|CPE_NAME=\"cpe:/o:winblues:${IMAGE_PRETTY_NAME,}|" \
    "s/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME=\"${DEFAULT_HOSTNAME,}\"/" \
    "s/^ID=fedora/ID=${IMAGE_PRETTY_NAME,}\nID_LIKE=\"${IMAGE_LIKE}\"/" \

# Add ID_LIKE tag to allow external apps to properly identify that this is based on Fedora Kinoite.
echo "ID_LIKE=\"${IMAGE_LIKE}\"" >> /usr/lib/os-release

# Fix issues caused by ID no longer being fedora.
sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg

# ››› Switch to generic-logos.
#
swap fedora-logos generic-logos

# endregion

# endregion

#  ··· Packages
#      + install/uninstall other packages.
#
# region packages

# Remove: ujust, Firefox
#
uninstall ublue-os-just \
          firefox

# Setup: Terra
#
enable-repo-from-url terra https://github.com/terrapkg/subatomic-repos/raw/main
install terra-release
defer uninstall terra-release

# Install: desktop applications
#
install @development-tools \
        elisa \
        gwenview \
        haruna \
        just \
        kalk \
        kamoso \
        kclock \
        kcm_systemd \
        kcolorchooser \
        kolourpaint \
        krdc \
        ksystemlog \
        lm_sensors \
        merkuro \
        okular \
        plasma-browser-integration \
        yakuake 


# Install: desktop tweaks + Walker/Elephant
#
enable-copr-dd matinlotfali/KDE-Rounded-Corners
# enable-copr-dd errornointernet/walker
enable-copr-dd deltacopy/plasma6-applets-kara 
install kwin-effect-roundcorners \
        plasma6-applets-kara
        # elephant \
        # elephant-calc \
        # elephant-desktopapplications \
        # elephant-files \
        # elephant-symbols \
        # elephant-unicode \
        # elephant-windows \
        # walker \

# Install: command-line and core applications
#
install bat \
        btop \
        distrobox \
        eza \
        fastfetch \
        fd \
        fish \
        ghostty \
        helix \
        podman-docker \
        podman-compose \
        ripgrep \
        rclone \
        starship \
        topgrade \
        vim \
        xlsclients \
        zoxide

# Install: virtualisation stack (libvirt/QEMU/KVM)
#
install @virtualization

# Install: IMEs (jp/bn)
#
enable-copr-dd badshah/openbangla-keyboard
install fcitx5 \
        fcitx5-mozc \
        kcm-fcitx5 \
        fcitx-openbangla

# Install: Syncthing and SyncthingTray (Plasmoid/KIO/CLI)
#
enable-obs-repo-dd home:mkittler
install syncthing \
        syncthingplasmoid-qt6 \
        syncthingfileitemaction-qt6 \
        syncthingctl-qt6

# Install: printer drivers (brlaser)
#
install printer-driver-brlaser

# Install: browsers (Zen, Helium)
#
# FIX: The zen-browser package needs to throw some stuff in /opt, which doesn't exist, so we'll
#      manually (rem)make the /opt directory (replacing the existing one which is just a symlink
#      to /var/opt)
rm /opt && mkdir /opt
enable-copr-dd sneexy/zen-browser
install zen-browser \
        helium-browser-bin

# Install: Tailscale
#
enable-repo-from-url-dd tailscale https://pkgs.tailscale.com/stable/fedora
install tailscale

# endregion

#  ··· Finalisation
#      + run cleanup tasks.
#      + create container commit.
#
# region finalisation
run-defer
ostree container commit
# endregion