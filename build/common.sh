#!/bin/bash
set -ouex pipefail

#  ··· Common helper functions.
#

# ››› Install a set of applications with dnf5.
#
install() {
    dnf5 install -y "$@"
}

# ››› Install a set of applications from a specified COPR with dnf5.
#
install-from-copr() {
    copr="$1" && shift
    dnf5 copr enable "$copr" -y
    dnf5 install "$@" -y
    dnf5 copr disable "$copr" -y
}

# ››› Install a set of applications from a specified OBS with dnf5.
#
install-from-obs-repo() {
    repo="$1" && shift
    release="Fedora_$(awk -F= '/VERSION_ID/ {print $2}' /etc/os-release)"
    url="https://download.opensuse.org/repositories/$repo/$release/$repo.repo"
    
    dnf5 config-manager addrepo -y --from-repofile="$url"
    dnf5 install "$@" -y
    rm "/etc/yum.repos.d/$repo.repo"
}