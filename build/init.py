#!/bin/env python
from unibuild import Setup  # pyright: ignore[reportImplicitRelativeImport]


def main():
    setup = Setup(verbose=True)

    setup.core.vprint(r"# ----****#####****---- ")
    setup.core.vprint(r"#                       ")
    setup.core.vprint(r"#      _ _  _ _/_. _    ")
    setup.core.vprint(r"#     / / //_'/ /_\     ")
    setup.core.vprint(r"#                       ")
    setup.core.vprint(r"# ----****#####****---- ")
    setup.core.vprint()

    setup.core.vprint(f"# INFO: Verbose mode is {'on' if setup.verbose else 'off'}.")
    setup.core.vprint(f"# INFO: Image based on: Fedora {setup.identity.fedora_release()}.")

    # Set basic branding.
    #
    setup.identity.set_basic_identity_info(
        image_vendor="jahinzee",
        image_name="metis",
        image_pretty_name="Metis",
        use_github_conventions=True,
        base_image_name="Kinoite",
        base_image_url="ghcr.io/ublue-os/kinoite-main",
    )

    # Swap: fedora-logos -> generic-logos.
    #
    setup.pkgs.swap("fedora-logos", "generic-logos")

    # Setup: Terra
    #
    setup.repos.enable_url_repo("terra", "https://github.com/terrapkg/subatomic-repos/raw/main")
    setup.pkgs.install("terra-release")

    with (
        setup.repos.ctx_copr("matinlotfali", "KDE-Rounded-Corners"),
        setup.repos.ctx_copr("deltacopy", "plasma6-applets-kara"),
        setup.repos.ctx_copr("badshah", "openbangla-keyboard"),
        setup.repos.ctx_obs_repo("home:mkittler"),
    ):
        setup.pkgs.install(
        
            # Install: desktop apps and tweaks
            #
            "helium-browser-bin",
            "kwin-effect-roundcorners",
            "plasma6-applets-kara",
            "yakuake",
        
            # Install: command-line and core applications, Nix, and virtualisation stack
            #          (libvirt/QEMU/KVM)
            #
            "@development-tools",
            "@virtualization",
            "nix",
            "git",
            "tailscale",
            "distrobox",
            "lm_sensors",
            "podman-docker",

            # Install: IMEs (jp/bn)
            #
            "fcitx5",
            "fcitx5-mozc",
            "kcm-fcitx5",
            "fcitx5-openbangla",

            # Install: Syncthing and SyncthingTray (Plasmoid/KIO/CLI)
            #
            "syncthing",
            "syncthingtray-qt6",
            "syncthingctl-qt6",

            # Install: printer drivers (brlaser)
            #  
            "printer-driver-brlaser"
        )  # fmt: skip

    # Finalisation
    #
    setup.core.vprint(r"# ----****#####****---- ")
    setup.core.vprint(r"#    Setup complete!    ")
    setup.core.vprint(r"# ----****#####****---- ")

    setup.core.finalise()


if __name__ == "__main__":
    main()
