## Maintenance Notes

List of things to be aware of for future maintenance issues. If the system image breaks or there's
a build error, check here first for potential points of failure.

---

### Versioning

- Currently basing from `latest`, may consider pinning to specific major release and bumping
  manually as needed.

### External repositories

* **Terra**:
  <https://terrapkg.com/>

  - *Latest package versions (as of 2026-04-25)*: **44**

* **matinotfali/KDE-Rounded-Corners** (COPR):
  <https://copr.fedorainfracloud.org/coprs/matinlotfali/KDE-Rounded-Corners>

  - *Latest package versions (as of 2026-04-25)*: **44**

* **badshah/openbangla-keyboard** (COPR):
  <https://copr.fedorainfracloud.org/coprs/badshah/openbangla-keyboard>

  - *Latest package versions (as of 2026-04-25)*: **44**

* **home:mkittler** (OBS):
  <https://build.opensuse.org/project/show/home:mkittler>

  - *Latest package versions (as of 2026-04-25)*: **43** ⚠️

* **sneexy/zen-browser** (COPR):
  <https://copr.fedorainfracloud.org/coprs/sneexy/zen-browser>

  - *Latest package versions (as of 2026-04-25)*: **44**
  - See also: [Manual patches](#manual-patches)

* **Tailscale**:
  <https://pkgs.tailscale.com/stable/fedora>
  
  - *Latest package versions (as of 2026-04-25)*: unknown
  - Repair strategy: use `tailscale` package from Fedora repos.

### Manual patches

* Unsymlinking `/opt` for Zen Browser:
  [init.py:142](/build/init.py#L142)

