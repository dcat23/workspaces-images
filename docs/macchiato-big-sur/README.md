# macOS Big Sur Desktop

**A macOS Big Sur–styled XFCE desktop for Kasm, built on Ubuntu Noble.**

This workspace applies the [SmallSur](https://github.com/jothi-prasath/SmallSur) theme
stack to a standard Kasm Ubuntu Noble core image — delivering the WhiteSur GTK theme,
matching window decorations, Big Sur icon set, custom cursors, a semi-transparent top
panel, a Plank dock, and the full SmallSur wallpaper collection.

---

## What's Included

### Theme Stack

| Component | Source | Details |
|---|---|---|
| **GTK theme** | [WhiteSur-gtk-theme](https://github.com/jothi-prasath/WhiteSur-gtk-theme) | Dark + Light variants installed system-wide |
| **Icon theme** | [WhiteSur-icon-theme](https://github.com/vinceliuice/WhiteSur-icon-theme) | WhiteSur, WhiteSur-light, WhiteSur-dark |
| **Cursor theme** | [WhiteSur-cursors](https://github.com/vinceliuice/WhiteSur-cursors) | WhiteSur-cursors |
| **Window decorations** | WhiteSur-gtk-theme (xfwm4) | WhiteSur-Dark — traffic-light buttons on the left (`CHM\|O`) |
| **Dock** | [Plank](https://launchpad.net/plank) | Themed with `mcOS-BS-iMacM1-Black`; always visible; autostarts with session |
| **Wallpapers** | [SmallSur](https://github.com/jothi-prasath/SmallSur) | 5 wallpapers in `/usr/share/backgrounds/bigsur/` |
| **File manager** | [Nemo](https://github.com/linuxmint/nemo) | Replaces Thunar; includes `nemo-fileroller` archive integration |
| **Terminal emulator** | [Kitty](https://sw.kovidgoyal.net/kitty/) | Default terminal; registered via `exo-open` and `update-alternatives` |

### Default Active Settings

| Setting | Value |
|---|---|
| GTK theme | WhiteSur-Dark |
| Icon theme | WhiteSur-Dark |
| Cursor theme | WhiteSur-cursors |
| Window manager theme | WhiteSur-Dark |
| Window button layout | `CHM\|O` — Close/Hide/Maximize on the left, app icon on the right |
| Compositing | Enabled (`use_compositing=true`, `sync_to_vblank=false`) |
| Default wallpaper | `monterey.png` (set as `bg_default.png`) |
| Plank dock visibility | Always visible (`HideMode=0`) |
| Plank theme | mcOS-BS-iMacM1-Black |
| Panel background | `rgba(0, 0, 0, 0.30)` — 30% black tint (see-through) |
| Default file manager | Nemo |
| Default terminal | Kitty (shell: `/bin/bash`) |

### Top Panel Layout

```
[ App Icon ]  [ App Menu (appmenu) ]  ──── spacer ────  [ Date/Time ]  ──── spacer ────  [ Systray ]  [ Volume ]  [ Power ]
```

The global app menu (`xfce4-appmenu-plugin`) shows the current window's menu bar items
inline in the panel, similar to macOS. GTK2/GTK3 app menus are exported via
`appmenu-gtk-module`, loaded automatically at session start.

### XFCE Plugins Installed

| Plugin | Package |
|---|---|
| Global app menu | `xfce4-appmenu-plugin` + `appmenu-gtk{2,3}-module` + `appmenu-registrar` |
| Volume control | `xfce4-pulseaudio-plugin` |
| Power manager | `xfce4-power-manager` |
| Notifications | `xfce4-notifyd` |

### Additional Applications

| Application | Package(s) | Notes |
|---|---|---|
| **Nemo** | `nemo`, `nemo-fileroller` | Default file manager; replaces Thunar across all XFCE integration layers |
| **Kitty** | `kitty` | Default terminal emulator; registered via `exo-open` helper and `update-alternatives` (priority 50) |

---

## Wallpapers

All SmallSur wallpapers are installed to `/usr/share/backgrounds/bigsur/`:

| File | Style |
|---|---|
| `monterey.png` | Purple/blue gradient — **default** |
| `contours.png` | Abstract contour lines |
| `smallsur.png` | SmallSur brand gradient |
| `ventura.jpg` | macOS Ventura landscape |
| `cyberpunk.jpg` | Cyberpunk neon cityscape |

To switch wallpapers: right-click the desktop → **Desktop Settings** → **Background** →
navigate to `/usr/share/backgrounds/bigsur/`.

---

## Known Limitations

### Global App Menu

The `xfce4-appmenu-plugin` renders the active window's menu bar in the panel. However,
only apps that export their menus over DBus will show live menu items. Apps that do not
support the appmenu protocol (some GTK4 apps, Electron apps, Qt apps without the module)
display a fallback "Desktop" label.

The `appmenu-*` packages in the original SmallSur `install-debian.sh` relied on
`appmenu-*` glob packages that are unavailable on Ubuntu Noble. These have been replaced
with the equivalent Noble packages: `appmenu-gtk2-module`, `appmenu-gtk3-module`, and
`appmenu-registrar`.

### Dropped Packages (Unavailable on Ubuntu Noble)

| Package | Reason dropped | Effect |
|---|---|---|
| `xfce4-statusnotifier-plugin` | Merged into built-in `systray` plugin in XFCE 4.18 | None — `systray` handles both XEmbed and SNI tray icons |
| `xfce4-indicator-plugin` | Removed from Ubuntu repos after Focal | None in Kasm context |
| `xfce4-sensors-plugin` | Hardware sensor access unavailable in containers | None — no sensor readout in panel |

### Plank Dock

Plank autostarts via `/etc/xdg/autostart/plank.desktop`. It launches with the
`mcOS-BS-iMacM1-Black` theme, always-visible mode (`HideMode=0`), and icon zoom enabled.
Dock contents are not pre-populated with launchers — Plank will show only running
applications by default.

### Nemo File Manager

Nemo replaces the Thunar daemon that the Kasm core session normally starts via
`execThunar.sh`. A drop-in wrapper `execNemo.sh` sources `generate_container_user`
and launches `nemo --no-default-window` as the session daemon (Client3 in
`xfce4-session.xml`). MIME defaults for `inode/directory` are set both in the user
profile (`mimeapps.list`) and system-wide (`/etc/xdg/mimeapps.list`).

### Kitty Terminal

Kitty is registered as the default terminal via three layers: an `exo-open` helper
(`/usr/share/xfce4/helpers/kitty.desktop`), `helpers.rc`, and
`update-alternatives` at priority 50 (above xterm/xfce4-terminal). Kitty is
configured to use `/bin/bash` as its shell via `~/.config/kitty/kitty.conf`.

### Symlink Emblem on Desktop Icons

Kasm's Downloads and Uploads directories are exposed as symlinks. XFCE/GTK would
normally render an `emblem-symbolic-link` arrow badge on top of those folder icons.
This is suppressed by replacing `emblem-symbolic-link.png` in the
`hicolor` icon theme (sizes 16×16 through 48×48) with a transparent 1×1 PNG, so
the emblem inherits as invisible across all installed icon themes.

### Compositing

Compositing is enabled (`use_compositing=true`) with `sync_to_vblank=false` to avoid
frame-rate locking over the VNC/WebRTC transport. If you experience rendering artefacts
you can disable compositing via **Settings → Window Manager Tweaks → Compositor**.

### ulauncher

The SmallSur README recommends installing `ulauncher` (a Spotlight-style launcher) manually.
It is not included in this image because it is not available in the Ubuntu Noble apt
repositories. To add it, install the [ulauncher PPA](https://github.com/Ulauncher/Ulauncher)
after launching the container, or extend this dockerfile with a PPA layer.

---

## Adaptations from SmallSur `install-debian.sh`

This image does **not** run `install-debian.sh` from the SmallSur repository directly.
The original script is incompatible with a headless Docker build for several reasons:

| Original | Problem | Fix |
|---|---|---|
| `sudo apt install` | No sudo in Docker build (already root) | Removed `sudo` |
| `killall xfce4-panel` | No panel process running during build | Removed |
| `xfconf-query` calls | Requires a live XFCE/DBus session | Replaced with direct XML writes to `~/.config/xfce4/xfconf/xfce-perchannel-xml/` |
| `~/Pictures/`, `~/.local/share/icons/` | Relative to interactive user | Uses `$HOME` (`/home/kasm-default-profile`) and system-wide paths |
| GTK/icon themes → `~/.themes/`, `~/.local/share/icons/` | Per-user only | Installed system-wide to `/usr/share/themes/` and `/usr/share/icons/` |
| `install.sh -c dark` then `install.sh -c light` | Second call wipes the first install | Combined to single call: `install.sh -c dark -c light` |
| `SUDO_USER` / `logname` unset in build | WhiteSur `install.sh` calls `logname` to resolve `MY_USERNAME`; fails silently under `set -Eeo pipefail` | `export SUDO_USER=root` before all installer calls |
| Cursor path `dist/WhiteSur-cursors/` | Repo restructured — `dist/` is now the theme root | Uses cursor repo's own `install.sh` |
| Thunar as session file manager | Kasm core launches `execThunar.sh` as Client3; Thunar unstyled and lacks archive integration | `execNemo.sh` wrapper replaces it; Nemo registered across all XFCE layers |
| No terminal configured | Core image provides `xfce4-terminal`; no macOS-style terminal | Kitty installed and registered as the default terminal emulator |
| Symlink emblem arrow on desktop icons | XFCE shows a badge on Kasm's symlinked Downloads/Uploads directories | `emblem-symbolic-link.png` replaced with a transparent PNG in `hicolor` |

---

## Build

```bash
# From repository root
docker compose build big-sur

# Or directly
sudo docker build \
  -t macchiato23/kasm-big-sur:latest \
  -f dockerfile-macchiato-big-sur \
  .

# Against a specific core tag
sudo docker build \
  --build-arg BASE_TAG=1.16.0 \
  -t macchiato23/kasm-big-sur:1.0 \
  -f dockerfile-macchiato-big-sur \
  .
```

---

## Run

```bash
# Docker Compose
docker compose up big-sur

# Direct
sudo docker run --rm -it \
  --shm-size=512m \
  -p 6901:6901 \
  -e VNC_PW=password \
  macchiato23/kasm-big-sur:latest
```

Access via browser at `https://<host>:6901` — user: `kasm_user`, password: `password`.

---

## Image Metadata

| Field | Value |
|---|---|
| **Base image** | `kasmweb/core-ubuntu-noble:develop` |
| **Image name** | `macchiato23/kasm-big-sur:latest` |
| **Dockerfile** | `dockerfile-macchiato-big-sur` |
| **Install scripts** | `src/ubuntu/install/big_sur_theme/install_big_sur_theme.sh` |
| | `src/ubuntu/install/nemo/install_nemo.sh` |
| | `src/ubuntu/install/kitty/install_kitty.sh` |
| **Type** | Full desktop |

---

## Customization

### Change the wallpaper permanently

Override `bg_default.png` in your own dockerfile layer:

```dockerfile
FROM macchiato23/kasm-big-sur:latest
USER root
RUN cp /usr/share/backgrounds/bigsur/ventura.jpg /usr/share/backgrounds/bg_default.png
USER 1000
```

### Adjust panel transparency

The panel alpha is set in `src/ubuntu/install/big_sur_theme/install_big_sur_theme.sh`
inside the `xfce4-panel.xml` heredoc — the fourth `background-rgba` value:

```xml
<value type="double" value="0.300000"/>  <!-- 0.0 = transparent, 1.0 = opaque -->
```

Rebuild after changing it.

### Switch to light theme

Change the `ThemeName` and `IconThemeName` values in `xsettings.xml` from
`WhiteSur-Dark` to `WhiteSur-Light` in the install script and rebuild.
