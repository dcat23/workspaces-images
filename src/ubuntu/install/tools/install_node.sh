#!/bin/bash

apt-get update

NVM_VERSION="v0.39.5"

# Install NVM 
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash

# Close and reopen your terminal to start using nvm 
# or run the following to use it now:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Install latest node
nvm install node

# Install package managers
npm install -g pnpm yarn