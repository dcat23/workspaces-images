#!/usr/bin/env bash
set -ex

# Install Claude Code — downloads binary and runs `claude install` to set up launcher
curl -fsSL https://claude.ai/install.sh | bash

# The installer may hardcode the build-time HOME into .bashrc; normalize to $HOME
sed -i "s|${HOME}/.local/bin|\$HOME/.local/bin|g" "$HOME/.bashrc"

# Ensure all login shells (interactive and non-interactive) have claude in PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' > /etc/profile.d/claude_code.sh

# System-wide wrapper so 'claude' resolves regardless of whether a login shell is active.
# At runtime kasm copies kasm-default-profile → kasm-user, so $HOME/.local/bin/claude
# will exist under the correct runtime HOME.
cat > /usr/local/bin/claude <<'WRAPPER'
#!/usr/bin/env bash
exec "$HOME/.local/bin/claude" "$@"
WRAPPER
chmod +x /usr/local/bin/claude

# Cleanup
chown -R 1000:0 $HOME
find /usr/share/ -name "icon-theme.cache" -exec rm -f {} \;
if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*
fi
