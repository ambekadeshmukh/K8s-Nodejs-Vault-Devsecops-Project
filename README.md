# Secure Node.js Deployment with DevSecOps Pipeline

**Note:** This repository uses the `main` branch as the default branch.

This project demonstrates a complete DevSecOps implementation for deploying a secure Node.js web application using modern cloud-native technologies. It incorporates security at every stage of the deployment pipeline.

## Architecture Overview

![DevSecOps Architecture](./architecture-diagram.png)

This project implements:

- **Infrastructure as Code** using Terraform
- **Containerization** with Docker
- **CI/CD pipeline** with Jenkins
- **Container vulnerability scanning** with Trivy
- **Secret management** with HashiCorp Vault
- **Orchestration** with Kubernetes (AWS EKS)
- **Security policies** with Kubernetes RBAC, PodSecurityPolicies, and NetworkPolicies

## Prerequisites

Before starting the project, ensure you have:

1. **AWS Account** with appropriate permissions to create EKS clusters
2. **Local development environment** with the following tools installed:
   - Git
   - Docker & Docker CLI (20.10.x or newer)
   - Kubernetes CLI (kubectl v1.21.x or newer)
   - AWS CLI v2 (configured with proper credentials)
   - Terraform (v1.0.0+)
   - HashiCorp Vault CLI (1.8.x or newer)
   - Node.js (v14.x or newer) and npm

3. **GitHub Account** to host your code repository
4. **DockerHub Account** to store container images

## Project Structure

```
.
├── app/                    # Node.js application code
│   ├── app.js
│   ├── package.json
│   └── Dockerfile
├── infrastructure/         # Terraform IaC files
│   ├── eks-cluster.tf
│   ├── network.tf
│   ├── variables.tf
│   └── outputs.tf
├── jenkins/                # Jenkins configuration
│   └── Jenkinsfile
├── kubernetes/             # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── pod-security-policy.yaml
│   ├── rbac.yaml
│   └── network-policy.yaml
├── scripts/                # Helper scripts
│   ├── install-jenkins.sh
│   ├── setup-vault.sh
│   └── configure-kubectl.sh
├── architecture-diagram.png # Architecture visualization
└── README.md               # Project documentation
```

## Implementation Steps

### Phase 1: Infrastructure Setup

1. **Create the EKS Cluster using Terraform**
   ```bash
   cd infrastructure
   terraform init
   terraform apply
   ```

2. **Configure kubectl to connect to the EKS cluster**
   ```bash
   aws eks --region us-west-2 update-kubeconfig --name devsecops-cluster
   ```

3. **Install and configure Jenkins**
   ```bash
   cd scripts
   chmod +x install-jenkins.sh
   ./install-jenkins.sh
   ```

### Phase 2: Application Setup

1. **Create and build the Node.js application**
   ```bash
   cd app
   npm install
   docker build -t your-dockerhub-username/devsecops-nodejs-app:latest .
   ```

2. **Test the application locally**
   ```bash
   docker run -p 3000:3000 your-dockerhub-username/devsecops-nodejs-app:latest
   ```
   
   Access http://localhost:3000 to verify the application is running.

### Phase 3: Jenkins CI/CD Pipeline

1. **Set up the Jenkins pipeline using the Jenkinsfile**
   - Create a new pipeline job in Jenkins
   - Configure it to use the Jenkinsfile from your repository
   - Add DockerHub credentials in Jenkins credentials manager

2. **Run the pipeline to build, scan, and deploy the application**

### Phase 4: Security Setup

1. **Install and configure HashiCorp Vault**
   ```bash
   cd scripts
   chmod +x setup-vault.sh
   ./setup-vault.sh
   ```

2. **Create Kubernetes security policies**
   ```bash
   kubectl apply -f kubernetes/pod-security-policy.yaml
   kubectl apply -f kubernetes/rbac.yaml
   kubectl apply -f kubernetes/network-policy.yaml
   ```

### Phase 5: Application Deployment

1. **Deploy the application to Kubernetes**
   ```bash
   kubectl apply -f kubernetes/deployment.yaml
   kubectl apply -f kubernetes/service.yaml
   ```

2. **Verify the deployment**
   ```bash
   kubectl get deployments
   kubectl get pods
   kubectl get services
   ```

3. **Access the application**
   ```bash
   export SERVICE_IP=$(kubectl get services devsecops-nodejs-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
   curl http://$SERVICE_IP
   ```

## Security Features

This project implements several key security features:

1. **Container Security**: Application is isolated in containers with vulnerability scanning
2. **Image Scanning**: Docker images are scanned for vulnerabilities with Trivy
3. **Secret Management**: Sensitive data is managed by HashiCorp Vault
4. **RBAC**: Role-Based Access Control for Kubernetes resources
5. **Pod Security Policies**: Enforce security standards for pods
6. **Network Policies**: Control communication between pods
7. **Secure CI/CD Pipeline**: Security checks at each stage of the pipeline

## Cleanup

To clean up all resources created by this project:

1. Delete Kubernetes resources
   ```bash
   kubectl delete -f kubernetes/
   ```

2. Destroy the EKS cluster
   ```bash
   cd infrastructure
   terraform destroy
   ```

## Troubleshooting

Common issues and their solutions:

1. **Jenkins pipeline fails at Docker build**
   - Check if Jenkins has permissions to access Docker
   - Ensure DockerHub credentials are correctly configured

2. **EKS cluster creation fails**
   - Verify AWS credentials are properly set up
   - Check IAM permissions for creating EKS clusters

3. **Vault integration issues**
   - Ensure Vault is properly initialized and unsealed
   - Verify Kubernetes auth method is configured correctly