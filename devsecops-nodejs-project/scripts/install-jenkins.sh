#!/bin/bash
# This script installs Jenkins, Docker, and required plugins for DevSecOps pipeline

set -e  # Exit on any error

# Update system packages
echo "Updating system packages..."
sudo apt update

# Install Java (required for Jenkins)
echo "Installing Java..."
sudo apt install -y openjdk-11-jdk

# Add Jenkins repository and install Jenkins
echo "Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins

# Start Jenkins
echo "Starting Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Docker
echo "Installing Docker..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add jenkins user to docker group
echo "Adding jenkins user to docker group..."
sudo usermod -aG docker jenkins

# Restart Jenkins to apply changes
echo "Restarting Jenkins..."
sudo systemctl restart jenkins

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Trivy scanner
echo "Installing Trivy vulnerability scanner..."
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin v0.34.0

# Output Jenkins initial admin password
echo "---------------------------------------------------"
echo "Jenkins installed successfully!"
echo "Initial admin password: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
echo "Access Jenkins at: http://your-server-ip:8080"
echo "---------------------------------------------------"
echo "Please install the following Jenkins plugins manually:"
echo "- Docker Pipeline"
echo "- Kubernetes"
echo "- Kubernetes CLI"
echo "- HashiCorp Vault"
echo "- Blue Ocean"
echo "---------------------------------------------------"