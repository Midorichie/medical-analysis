#!/bin/bash
# scripts/setup-env.sh

# Exit on error
set -e

echo "Setting up Medical Image Analysis environment..."

# Check for required tools
command -v clarinet >/dev/null 2>&1 || {
    echo "Installing Clarinet..."
    curl -L https://github.com/hirosystems/clarinet/releases/download/v1.0.0/clarinet-linux-x64.tar.gz | tar xz
    sudo mv clarinet /usr/local/bin/
}

command -v npm >/dev/null 2>&1 || {
    echo "Please install Node.js and npm first"
    exit 1
}

# Create necessary directories
mkdir -p contracts/models
mkdir -p tests/utils
mkdir -p scripts
mkdir -p artifacts

# Install dependencies
npm install \
    @stacks/transactions \
    @stacks/network \
    @types/node \
    typescript \
    ts-node

# Create environment files
cat > .env << EOL
NETWORK_TYPE=testnet
STACKS_PRIVATE_KEY=your_private_key_here
STACKS_ADDRESS=your_stacks_address_here
EOL

# Setup test environment
cat > ./settings/Mocknet.toml << EOL
[network]
name = "mocknet"
deployment_fee_rate = 10

[accounts.deployer]
mnemonic = "fetch outside black test wash cover just actual execute nice door want airport betray quantum stamp fish act pen trust portion fatigue scissors vague"
balance = 1_000_000
EOL

echo "Environment setup complete!"
echo "Please update .env with your private key and address"

# Make script executable
chmod +x scripts/deploy.ts

echo "Run 'npm test' to verify setup"
