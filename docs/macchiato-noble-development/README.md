# macchiato-noble-development

**A full Ubuntu Noble development desktop for Kasm with Docker-in-Docker (privileged), pre-loaded with a complete developer toolchain.**

Built on the `macchiato23/kasm-core-macchiato-noble` base image. Runs a root Docker daemon via supervisor, suitable for workflows that require full Docker access inside the workspace.

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
| Docker Engine | `src/ubuntu/install/dind/install_dind.sh` |
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
docker compose build noble-development

# Direct
docker build \
  -t macchiato23/kasm-macchiato-noble-development:develop \
  -f dockerfile-macchiato-noble-development \
  .
```

---

## Run

```bash
# Docker Compose
docker compose up noble-development

# Direct (privileged required for Docker-in-Docker)
docker run --rm -it \
  --privileged \
  --shm-size=512m \
  -p 6901:6901 \
  -e VNC_PW=password \
  macchiato23/kasm-macchiato-noble-development:develop
```

Access via browser at `https://<host>:6901` — user: `kasm_user`, password: `password`.

---

## Image Metadata

| Field | Value |
|---|---|
| **Base image** | `macchiato23/kasm-core-macchiato-noble:develop` |
| **Image name** | `macchiato23/kasm-macchiato-noble-development:develop` |
| **Dockerfile** | `dockerfile-macchiato-noble-development` |
| **Type** | Full desktop / DinD |
| **Install scripts** | `src/ubuntu/install/dind/` |
| | `src/ubuntu/install/misc/` |
| | `src/ubuntu/install/tools/` |
| | `src/ubuntu/install/brave/` |
| | `src/ubuntu/install/vs_code/` |
| | `src/ubuntu/install/intellij/` |
| | `src/ubuntu/install/postman/` |
| | `src/ubuntu/install/thunderbird/` |

---

## Known Limitations

### Privileged Mode Required

The Docker daemon runs as root inside the container. This image must be started with `--privileged` (or `privileged: true` in Compose). Use `macchiato-noble-development-rootless` if a non-privileged setup is preferred.

### Electron Apps and Sandboxing

VS Code and Postman are Electron/Chromium-based apps. The kernel namespace sandbox (`--sandbox`) is not available inside a Docker container, so `--no-sandbox` is applied to their `.desktop` launchers at build time. This is standard practice for containerised Kasm workspaces.
