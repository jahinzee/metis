#!/bin/bash
set -ouex pipefail

#  ··· Common helper functions.
#

# ››› Install a set of applications with dnf5.
#
install() {
    dnf5 install -y "$@"
}

# ››› Remove a set of applications with dnf5.
remove() {
    dnf5 remove -y "$@"
}

# ››› Install a set of applications from a specified COPR with dnf5.
#
install-from-copr() {
    copr="$1" && shift
    dnf5 copr enable "$copr" -y
    dnf5 install "$@" -y
    dnf5 copr disable "$copr" -y
}

# ››› Install a set of applications from a specified OBS repository with dnf5.
#
install-from-obs-repo() {
    repo="$1" && shift
    release="Fedora_$(awk -F= '/VERSION_ID/ {print $2}' /etc/os-release)"
    url="https://download.opensuse.org/repositories/$repo/$release/$repo.repo"
    
    dnf5 config-manager addrepo -y --from-repofile="$url"
    dnf5 install "$@" -y
    rm "/etc/yum.repos.d/$repo.repo"
}

# ››› Enable a set of COPRs, and save it to a context file.
#
enable-coprs() {
    for copr in "$@"; do
        dnf5 copr enable "$copr" -y
        echo "$copr" >> .ctx-coprs
    done
}

# ››› Enable a set of OBS repositories, and save it to a context file.
#
enable-obs-repos() {
    release="Fedora_$(awk -F= '/VERSION_ID/ {print $2}' /etc/os-release)"
    for repo in "$@"; do
        url="https://download.opensuse.org/repositories/$repo/$release/$repo.repo"
        dnf5 config-manager addrepo -y --from-repofile="$url"
        echo "$repo" >> .ctx-obs-repos
    done
}

# ››› Disable all COPRs from the context file.
#
clean-coprs() {
    while read -r copr; do
        dnf5 copr disable "$copr" -y
    done < .ctx-coprs
    rm .ctx-coprs
}

# ››› Delete all OBS repositories from the context file.
#
clean-obs-repos() {
    while read -r repo; do
        rm "/etc/yum.repos.d/$repo.repo"
    done < .ctx-obs-repos
    rm .ctx-obs-repos
}

# ››› Perform all cleanup actions.
#
clean-all() {
    clean-coprs
    clean-obs-repos
}