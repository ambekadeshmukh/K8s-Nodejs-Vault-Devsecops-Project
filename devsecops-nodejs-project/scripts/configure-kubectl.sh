#!/bin/bash
# This script configures kubectl to connect to the EKS cluster

set -e  # Exit on any error

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform output variables are available
if [ ! -f "../infrastructure/terraform.tfstate" ]; then
    echo "Terraform state file not found. Please run Terraform first."
    exit 1
fi

# Get EKS cluster name and region from Terraform outputs
cd ../infrastructure
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region)
cd ../scripts

echo "Configuring kubectl for EKS cluster: $CLUSTER_NAME in region: $REGION"

# Update kubeconfig to connect to EKS cluster
aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME

# Verify connection
echo "Verifying connection to EKS cluster..."
kubectl cluster-info

# Create Kubernetes namespace
echo "Creating kubernetes namespace for application..."
kubectl create namespace devsecops-app

# Create service account for Vault integration
echo "Creating service account for Vault authentication..."
kubectl create serviceaccount vault-auth

# Create cluster role binding for Vault authentication
echo "Creating cluster role binding for Vault authentication..."
kubectl create clusterrolebinding vault-auth-binding \
    --clusterrole=system:auth-delegator \
    --serviceaccount=default:vault-auth

echo "---------------------------------------------------"
echo "kubectl configured successfully!"
echo "Current context: $(kubectl config current-context)"
echo "---------------------------------------------------"