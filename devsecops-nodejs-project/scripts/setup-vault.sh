#!/bin/bash
# This script installs and configures HashiCorp Vault for Kubernetes integration

set -e  # Exit on any error

# Install Vault
echo "Installing HashiCorp Vault..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install -y vault

# Create Vault config directory
echo "Creating Vault configuration..."
sudo mkdir -p /etc/vault.d
sudo tee /etc/vault.d/vault.hcl > /dev/null <<EOF
storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "http://127.0.0.1:8200"
ui = true
EOF

# Create Vault data directory
sudo mkdir -p /opt/vault/data
sudo chown -R vault:vault /opt/vault

# Create Vault systemd service
sudo tee /etc/systemd/system/vault.service > /dev/null <<EOF
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitIntervalSec=60
StartLimitBurst=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Start Vault service
echo "Starting Vault service..."
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault

# Give Vault a moment to start
sleep 5

# Initialize Vault
echo "Initializing Vault (this will generate unseal keys and root token)..."
export VAULT_ADDR='http://127.0.0.1:8200'
vault_init=$(vault operator init -format=json)

# Extract unseal keys and root token
unseal_key_1=$(echo $vault_init | jq -r '.unseal_keys_b64[0]')
unseal_key_2=$(echo $vault_init | jq -r '.unseal_keys_b64[1]')
unseal_key_3=$(echo $vault_init | jq -r '.unseal_keys_b64[2]')
root_token=$(echo $vault_init | jq -r '.root_token')

# Unseal vault
echo "Unsealing Vault..."
vault operator unseal $unseal_key_1
vault operator unseal $unseal_key_2
vault operator unseal $unseal_key_3

# Create vault-init.json file for reference (STORE THESE SECURELY IN PRODUCTION)
echo $vault_init > vault-init.json

echo "Setting up Vault authentication for Kubernetes..."
# Set VAULT_TOKEN to root token
export VAULT_TOKEN=$root_token

# Enable Kubernetes authentication
vault auth enable kubernetes

echo "Creating Vault policy for application..."
# Create policy for application
vault policy write devsecops-app - <<EOF
path "secret/data/devsecops/*" {
  capabilities = ["read"]
}
EOF

echo "Creating example secret for application..."
# Enable KV secrets engine
vault secrets enable -path=secret kv-v2

# Create example secret
vault kv put secret/devsecops/app-secret \
  secret-message="This is a secret managed by HashiCorp Vault!" \
  api-key="vault-managed-api-key-example" \
  environment="development"

echo "---------------------------------------------------"
echo "Vault has been set up successfully!"
echo "Root Token: $root_token"
echo "Unseal Key 1: $unseal_key_1"
echo "Unseal Key 2: $unseal_key_2"
echo "Unseal Key 3: $unseal_key_3"
echo ""
echo "IMPORTANT: Store these keys securely in production!"
echo "The keys have been saved to './vault-init.json' for reference."
echo "---------------------------------------------------"
echo "To configure Vault for Kubernetes authentication, run:"
echo "kubectl create serviceaccount vault-auth"
echo "kubectl create clusterrolebinding vault-auth-binding --clusterrole=system:auth-delegator --serviceaccount=default:vault-auth"
echo "---------------------------------------------------"