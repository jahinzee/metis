#!/bin/env python
from unibuild import Setup


def main():
    setup = Setup(verbose=True, dry_run=False)

    setup.core.vprint("# --**## Metis ##**-- ")
    setup.core.vprint(f"# INFO: Verbose mode is {'on' if setup.verbose else 'off'}.")
    setup.core.vprint(f"# INFO: Dry run is {'on' if setup.dry_run else 'off'}.")
    setup.core.vprint(f"# INFO: Image based on: Fedora {setup.identity.fedora_release()}.")

    # BRANDING: set basic branding and swap logos.
    #
    setup.identity.set_basic_identity_info(
        use_github_conventions=True,
        image_vendor="jahinzee",
        image_name="metis",
        image_pretty_name="Metis",
        base_image_name="Kinoite",
        base_image_url="ghcr.io/ublue-os/kinoite-main")  # fmt: skip
    setup.pkgs.swap("fedora-logos", "generic-logos")

    # INSTALL: Base packages
    #
    setup.core.unsymlink_directory("/opt")  # PATCH: Fix /opt for Helium browser
    with (setup.repos.ctx_copr("badshah", "openbangla-keyboard"),
          setup.repos.ctx_copr("imput", "helium")):  # fmt: skip
        setup.pkgs.install(
            "@development-tools",
            "@virtualization",
            "distrobox",
            "fcitx-openbangla",
            "fcitx5-mozc",
            "fcitx5",
            "helium-bin",
            "nix",
            "nix-daemon",
            "pipx",
            "podman-compose",
            "podman-docker",
            "podman",
            "syncthing",
            "tailscale",
            "yakuake")  # fmt: skip

    # INSTALL: Base services
    #
    setup.systemd.make_unit("nix.mount", {
        "Unit": {
            "Description": "Bind mount /var/nix to /nix for atomic system compatibility."},
        "Mount": {
            "What": "/var/nix",
            "Where": "/nix",
            "Type": "none",
            "Options": "bind"},
        "Install": {
            "WantedBy": "local-fs.target"}},
            enable=True)  # fmt: skip
    setup.systemd.enable_unit("nix-daemon.service")
    setup.systemd.enable_unit("tailscaled.service")

    # FINALISE
    #
    setup.core.finalise()
    setup.core.vprint("# --**## Setup complete! ##**-- ")


if __name__ == "__main__":
    main()
