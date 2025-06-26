# metis

An atomic distro for an audience of one (me).

> [!WARNING]
> This image is made for my own personal use. If you choose to use this for
> whatever reason, I cannot help you if something breaks.

## Further Links

- The original [image-template](/docs/old-readme.md) README for reference.
- [Package notes](/docs/package-notes.md), mainly for documenting COPRs in use.

## Usage

### Rebasing to Metis

ISO building is very flaky at the moment, so we'll be using the good ol'
"rebase from another install" method.


1. Install another Fedora Atomic or Universal Blue image, I recommend
   [Kinoite](https://fedoraproject.org/atomic-desktops/kinoite/).


2. Open Konsole and run this command to rebase to the unsigned variant of this
   image (we'll re-rebase to the signed one later, but we have to go unsigned
   for a moment.)

   ```sh
   rpm-ostree rebase ostree-unverified-registry:ghcr.io/jahinzee/metis
   ```

3. Reboot the system.

   ```sh
   systemctl reboot # or use the power options from the desktop.
   ```

4. Open Konsole again and run this command to now rebase onto the signed
   variant.

   ```sh
   rpm-ostree rebase ostree-image-signed:docker://ghcr.io/
   ```

5. Reboot once again.

### Rebasing back to your previous image

