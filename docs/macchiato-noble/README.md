# macchiato-noble

**A full Ubuntu Noble desktop for Kasm, pre-loaded with a productivity and communication app suite.**

Built on the `macchiato23/kasm-core-macchiato-noble` base image, this workspace ships a curated set of applications ready to use from the desktop — no post-launch installation required.

---

## What's Included

### Applications

| Application | Package / Source | Notes |
|---|---|---|
| **Firefox** | Mozilla PPA | Default web browser |
| **Thunderbird** | `thunderbird` | Email client |
| **VS Code** | Microsoft direct download | Code editor; `--no-sandbox` applied |
| **Brave Browser** | Brave apt repo | Chromium-based browser |
| **OnlyOffice** | OnlyOffice installer | Office suite (Writer, Calc, Imager) |
| **Zoom** | Zoom direct download | Video conferencing |
| **Teams for Linux** | GitHub releases (IsmaelMartinez/teams-for-linux) | Microsoft Teams Electron wrapper; `--no-sandbox` applied |
| **Discord** | Discord direct download | Chat / voice; `--no-sandbox` applied |
| **Nextcloud** | Nextcloud installer | Cloud file sync client |

### Base Tools

| Component | Source |
|---|---|
| Alias CLI | `src/ubuntu/install/tools/install_alias_cli.sh` |
| Misc tools | `src/ubuntu/install/misc/install_tools.sh` |

---

## Build

```bash
# Docker Compose (from repo root)
docker compose build noble

# Direct
docker build \
  -t macchiato23/kasm-macchiato-noble:develop \
  -f dockerfile-macchiato-noble \
  .

# Against a specific core tag
docker build \
  --build-arg BASE_TAG=1.16.0 \
  -t macchiato23/kasm-macchiato-noble:1.0 \
  -f dockerfile-macchiato-noble \
  .
```

---

## Run

```bash
# Docker Compose
docker compose up noble

# Direct
docker run --rm -it \
  --shm-size=512m \
  -p 6901:6901 \
  -e VNC_PW=password \
  macchiato23/kasm-macchiato-noble:develop
```

Access via browser at `https://<host>:6901` — user: `kasm_user`, password: `password`.

---

## Image Metadata

| Field | Value |
|---|---|
| **Base image** | `macchiato23/kasm-core-macchiato-noble:develop` |
| **Image name** | `macchiato23/kasm-macchiato-noble:develop` |
| **Dockerfile** | `dockerfile-macchiato-noble` |
| **Type** | Full desktop |
| **Install scripts** | `src/ubuntu/install/misc/` |
| | `src/ubuntu/install/tools/` |
| | `src/ubuntu/install/firefox/` |
| | `src/ubuntu/install/thunderbird/` |
| | `src/ubuntu/install/vs_code/` |
| | `src/ubuntu/install/brave/` |
| | `src/ubuntu/install/only_office/` |
| | `src/ubuntu/install/zoom/` |
| | `src/ubuntu/install/teams/` |
| | `src/ubuntu/install/discord/` |
| | `src/ubuntu/install/nextcloud/` |

---

## Known Limitations

### Electron Apps and Sandboxing

Brave, VS Code, Teams for Linux, and Discord are Electron/Chromium-based apps. The kernel
namespace sandbox (`--sandbox`) is not available inside a Docker container, so all four
have `--no-sandbox` applied to their `.desktop` launchers at build time. This is standard
practice for containerized Kasm workspaces.

### Teams for Linux

This image ships the community-maintained
[teams-for-linux](https://github.com/IsmaelMartinez/teams-for-linux) Electron wrapper
rather than an official Microsoft binary. Microsoft discontinued their native Teams for
Linux `.deb` package in 2023 — no official Linux package exists. The install script
fetches the latest release from GitHub at build time.

### D-Bus / systemd Warnings

Several tray and session applets (nm-applet, polkit, colord) emit D-Bus or systemd
warnings at startup. These are benign in a containerised environment and do not affect
functionality.
