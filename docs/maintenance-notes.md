## Maintenance Notes

List of things to be aware of for future maintenance issues. If the system image breaks or there's
a build error, check here first!

---

### `fcitx-openbangla`: Locked on F42 package

- Waiting for upstream to release official F43 packages, and for it to be available on a COPR repo 
  (e.g. `badshah/openbangla-keyboard`) to update as well
- Prefer to use an up-to-date COPR instead of upstream GitHub release, since the GH releases are on
  `2.0.0` (2020), and COPRs appear to build straight from the latest source (`3.0.0`+).

---

### `appimagelauncher`: Using GitHub Release builds

- No usable COPR is available for AppImageLauncher, probably cause the last stable version is from
  2020.
- **Will need to manually bump release URL for updates.**

---

### `kwin-effect-roundcorners`: Disabled

- Might be causing issues with Plasma 6.5 (needs further investigating)