# Amnesia Desktop

**Ephemeral, privacy-first Kasm workspace — Tails-inspired, not Tails.**

Amnesia Desktop is a Kasm workspace image built around anonymous, ephemeral
sessions. It bundles the tools Tails users rely on — Tor Browser, Thunderbird
with OpenPGP, KeePassXC, GnuPG, MAT2, OnionShare, and LibreOffice — while
preserving full Kasm compatibility (agent connectivity, noVNC streaming, file
transfer, clipboard, and audio).

---

## Software Included

| Tool | Purpose |
|------|---------|
| **Tor Browser** | Anonymous web browsing via the Tor network |
| **Thunderbird** | Email with built-in OpenPGP encryption |
| **KeePassXC** | Offline, encrypted password manager |
| **GnuPG / GPG** | PGP file and email encryption |
| **MAT2** | Strip metadata from documents, images, and media |
| **OnionShare** | Tor-based anonymous file sharing (if available) |
| **LibreOffice** | Full office suite |
| **Torsocks** | Route individual CLI commands through Tor |

---

## Privacy Model

Sessions run as ephemeral Kasm containers. **By default no data persists
beyond the current session** — this is the "amnesic" behavior the name refers to.

Additional hardening applied at build time:

- Bash history is discarded (`HISTFILE=/dev/null`) — no `.bash_history` on disk.
- GTK recently-used file list is locked to an empty state.
- Thunar thumbnail cache is disabled.
- XFCE terminal does not save scrollback history across sessions.

---

## Limitations vs Real Tails

| Feature | Tails (USB) | Amnesia Desktop |
|---------|-------------|-----------------|
| All traffic through Tor | Yes | **No** — only Tor Browser |
| Full-disk encryption | Yes | No |
| Hardware-level isolation | Yes | No |
| Amnesic sessions | Yes | Yes (ephemeral containers) |
| Persistent storage option | Optional | Optional (Kasm profiles) |
| Browser-based delivery | No | Yes (noVNC / Kasm) |

**Kasm's agent, noVNC streaming, and clipboard services use direct network
connections.** Routing all container traffic through Tor would break these
services. Only Tor Browser routes through Tor by default.

For maximum security in high-risk situations, boot real Tails from a verified
USB drive instead of using this workspace.

---

## Routing CLI Tools Through Tor

Prefix any TCP-based CLI command with `torsocks`:

```bash
torsocks curl https://check.torproject.org/api/ip
torsocks wget https://example.com/file
torsocks git clone https://github.com/user/repo
```

Run the built-in guide at any time:

```bash
amnesia-tor-help
```

---

## Build Instructions

```bash
# From the repository root:
sudo docker build \
  -t macchiato23/kasm-amnesia-desktop:latest \
  -f dockerfile-macchiato-amnesia-desktop \
  .

# Override base tag (default: develop):
sudo docker build \
  --build-arg BASE_TAG=1.16.0 \
  -t macchiato23/kasm-amnesia-desktop:1.0 \
  -f dockerfile-macchiato-amnesia-desktop \
  .
```

## Run with Docker Compose

```bash
docker compose up amnesia-desktop
```

## Run Instructions

```bash
sudo docker run --rm -it \
  --shm-size=512m \
  -p 6901:6901 \
  -e VNC_PW=password \
  macchiato23/kasm-amnesia-desktop:latest
```

Access via browser at `https://<host>:6901` (user: `kasm_user`, password: `password`).

---

## Image Metadata

- **Display Name:** Amnesia Desktop
- **Category:** Desktop
- **Base:** `kasmweb/core-ubuntu-jammy`
- **Image:** `macchiato23/kasm-amnesia-desktop:latest`
- **Dockerfile:** `dockerfile-kasm-amnesia-desktop`
- **Logo:** `amnesia-logo2.jpg` (ghost-in-onion motif; navy `#1e1b4b`, violet `#5b48cc`, teal `#4ecdc4`)

---

*Amnesia Desktop is inspired by [Tails](https://tails.boum.org) but is an
independent project. It does not use Tails or Tor branding and does not claim
to provide the same security guarantees.*
