# Secure Node.js Deployment with DevSecOps Pipeline

This project demonstrates a complete DevSecOps implementation for deploying a secure Node.js web application using modern cloud-native technologies. It incorporates security at every stage of the deployment pipeline.

## Architecture Overview

![DevSecOps-nodejs](https://github.com/user-attachments/assets/6b2f3d34-9857-4617-9662-a580488689b8)


This project implements:

- Infrastructure as Code using Terraform
- Containerization with Docker
- CI/CD pipeline with Jenkins
- Container vulnerability scanning with Trivy
- Secret management with HashiCorp Vault
- Orchestration with Kubernetes (AWS EKS)
- Security policies with Kubernetes RBAC, PodSecurityPolicies, and NetworkPolicies

## Prerequisites

Before starting the project, ensure you have:

1. **AWS Account** with appropriate permissions to create EKS clusters
2. **Local development environment** with the following tools installed:
   - Git
   - Docker & Docker CLI
   - Kubernetes CLI (kubectl)
   - AWS CLI (configured with proper credentials)
   - Terraform (v1.0.0+)
   - HashiCorp Vault CLI
   - Node.js and npm

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
   ```
   cd infrastructure
   terraform init
   terraform apply
   ```

2. **Configure kubectl to connect to the EKS cluster**
   ```
   aws eks --region us-west-2 update-kubeconfig --name devsecops-cluster
   ```

3. **Install and configure Jenkins**
   ```
   cd scripts
   ./install-jenkins.sh
   ```

### Phase 2: Application Setup

1. **Create and build the Node.js application**
   ```
   cd app
   npm install
   docker build -t your-dockerhub-username/devsecops-nodejs-app:latest .
   ```

2. **Test the application locally**
   ```
   docker run -p 3000:3000 your-dockerhub-username/devsecops-nodejs-app:latest
   ```

### Phase 3: Jenkins CI/CD Pipeline

1. **Set up the Jenkins pipeline using the Jenkinsfile**
   - Create a new pipeline job in Jenkins
   - Configure it to use the Jenkinsfile from your repository

2. **Run the pipeline to build, scan, and deploy the application**

### Phase 4: Security Setup

1. **Install and configure HashiCorp Vault**
   ```
   cd scripts
   ./setup-vault.sh
   ```

2. **Create Kubernetes security policies**
   ```
   kubectl apply -f kubernetes/pod-security-policy.yaml
   kubectl apply -f kubernetes/rbac.yaml
   kubectl apply -f kubernetes/network-policy.yaml
   ```

### Phase 5: Application Deployment

1. **Deploy the application to Kubernetes**
   ```
   kubectl apply -f kubernetes/deployment.yaml
   kubectl apply -f kubernetes/service.yaml
   ```

2. **Verify the deployment**
   ```
   kubectl get deployments
   kubectl get pods
   kubectl get services
   ```

3. **Access the application**
   ```
   export SERVICE_IP=$(kubectl get services devsecops-nodejs-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
   curl http://$SERVICE_IP
   ```

## Security Features

This project implements several key security features:

1. **Containerization**: Application is isolated in containers
2. **Image Scanning**: Docker images are scanned for vulnerabilities with Trivy
3. **Secret Management**: Sensitive data is managed by HashiCorp Vault
4. **RBAC**: Role-Based Access Control for Kubernetes resources
5. **Pod Security Policies**: Enforce security standards for pods
6. **Network Policies**: Control communication between pods

## Cleanup

To clean up all resources created by this project:

1. Delete Kubernetes resources
   ```
   kubectl delete -f kubernetes/
   ```

2. Destroy the EKS cluster
   ```
   cd infrastructure
   terraform destroy
   ```
