# macchiato-noble-development-rootless

**A full Ubuntu Noble development desktop for Kasm with rootless Docker-in-Docker, pre-loaded with a complete developer toolchain.**

Built on the `macchiato23/kasm-core-macchiato-noble` base image. Runs Docker as user 1000 via a rootless daemon — no `--privileged` flag required at runtime.

---

## What's Included

### Applications

| Application | Package / Source | Notes |
|---|---|---|
| **Brave Browser** | Brave apt repo | Chromium-based browser |
| **VS Code** | Microsoft direct download | Code editor; `--no-sandbox` applied |
| **IntelliJ IDEA** | JetBrains installer | Java/Kotlin IDE |
| **Postman** | Postman direct download | API development tool |
| **Thunderbird** | `thunderbird` | Email client |

### Developer Toolchain

| Component | Source |
|---|---|
| Docker Engine (rootless) | `src/ubuntu/install/dind_rootless/install_dind_rootless.sh` |
| Tools deluxe | `src/ubuntu/install/tools/install_tools_deluxe.sh` |
| Node.js | `src/ubuntu/install/tools/install_node.sh` |
| Java (JDK + JRE) | `default-jdk default-jre` (apt) |
| Maven | `maven` (apt) |
| Claude Code | `https://claude.ai/install.sh` |
| JetBrains reset trial | `src/ubuntu/install/tools/install_jetbrains_reset_trial.sh` |
| Alias CLI | `src/ubuntu/install/tools/install_alias_cli.sh` |
| Misc tools | `src/ubuntu/install/misc/install_tools.sh` |

---

## Build

```bash
# Docker Compose (from repo root)
docker compose build noble-development-rootless

# Direct
docker build \
  -t macchiato23/kasm-macchiato-noble-development-rootless:develop \
  -f dockerfile-macchiato-noble-development-rootless \
  .
```

---

## Run

```bash
# Docker Compose
docker compose up noble-development-rootless

# Direct
docker run --rm -it \
  --shm-size=512m \
  -p 6901:6901 \
  -e VNC_PW=password \
  macchiato23/kasm-macchiato-noble-development-rootless:develop
```

Access via browser at `https://<host>:6901` — user: `kasm_user`, password: `password`.

---

## Image Metadata

| Field | Value |
|---|---|
| **Base image** | `macchiato23/kasm-core-macchiato-noble:develop` |
| **Image name** | `macchiato23/kasm-macchiato-noble-development-rootless:develop` |
| **Dockerfile** | `dockerfile-macchiato-noble-development-rootless` |
| **Type** | Full desktop / DinD rootless |
| **Docker socket** | `unix:///docker/docker.sock` (`XDG_RUNTIME_DIR=/docker`) |
| **Install scripts** | `src/ubuntu/install/dind_rootless/` |
| | `src/ubuntu/install/misc/` |
| | `src/ubuntu/install/tools/` |
| | `src/ubuntu/install/brave/` |
| | `src/ubuntu/install/vs_code/` |
| | `src/ubuntu/install/intellij/` |
| | `src/ubuntu/install/postman/` |
| | `src/ubuntu/install/thunderbird/` |

---

## Known Limitations

### Rootless Docker Constraints

Rootless Docker does not support all Docker features. Network modes other than `bridge` and `host` may not work. Some images that require kernel capabilities (e.g. `NET_ADMIN`) will fail to start. Use `macchiato-noble-development` (privileged DinD) if full Docker compatibility is needed.

### Electron Apps and Sandboxing

VS Code and Postman are Electron/Chromium-based apps. The kernel namespace sandbox (`--sandbox`) is not available inside a Docker container, so `--no-sandbox` is applied to their `.desktop` launchers at build time. This is standard practice for containerised Kasm workspaces.
