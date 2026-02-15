# Secure AWS Platform — ECS Blue/Green CI/CD with Automated Rollback

A production-grade AWS platform demonstrating **secure infrastructure provisioning, automated CI/CD, blue/green deployments, and automatic rollback** using modern DevOps best practices.

This project simulates how a mid-size engineering organization would safely deploy containerized applications to AWS with zero downtime, strong IAM boundaries, and operational guardrails.

---
📋 Prerequisites
Before deploying this platform, ensure you have the following tools installed and configured:

- **Infrastructure as Code:** Terraform (v1.5+)

- **AWS CLI** installed and configured (aws sts get-caller-identity should succeed)

- **Containerization:** Docker  
  > Docker is required to build the application image in CI/CD.  
  > Docker Desktop is only needed locally if you want to test the container on your machine.

- **Version Control:** A GitHub account and a local Git client

---

## 🔹 Project Goals

- Build cloud infrastructure using **Infrastructure as Code (Terraform)**
- Deploy containerized applications using **ECS + Application Load Balancer**
- Implement **Blue/Green deployments with AWS CodeDeploy**
- Automate deployments using **GitHub Actions with OIDC (no static AWS keys)**
- Validate **automatic rollback** on deployment failure
- Enforce **state safety, cost control, and cleanup discipline**

---

## 🧱 Architecture Overview

This platform follows a **separation of concerns**:

- **Terraform** manages infrastructure
- **CodeDeploy** manages application deployments
- **GitHub Actions** handles CI/CD
- **ALB + Target Groups** control traffic
- **S3 + DynamoDB** protect Terraform state

> See the Architecture Diagram section below for a visual overview.

---

## 🏗️ Infrastructure Components

### Core AWS Services
- **Amazon ECS (Fargate)** — container orchestration
- **Application Load Balancer (ALB)** — traffic routing
- **AWS CodeDeploy (ECS Blue/Green)** — safe deployments & rollback
- **Amazon ECR** — container image registry
- **Amazon S3** — Terraform remote state & CodeDeploy revisions
- **Amazon DynamoDB** — Terraform state locking
- **IAM (OIDC)** — secure, short-lived CI/CD access

### Networking
- VPC with **public subnets**
- ALB exposed publicly for demonstration purposes  
  > A public subnet was intentionally chosen to simplify access and validation. In production, ECS services would typically run in private subnets behind NAT.

---
## 🚀 Getting Started
Follow these steps to provision the infrastructure and trigger your first automated deployment.

### 1. Clone the Repository

```bash
git clone https://github.com/GXZIIFTI/secure-aws-platform.git
cd secure-aws-platform
```
### 2. Configure Terraform Variables
```bash
cd ecs-cicd-bluegreen/infra
```
Edit terraform.tfvars:
`codedeploy_bucket = "<your-s3-bucket-for-appspec>"`
Initialize and apply the infrastructure:
```bash
terraform init
terraform apply
```

### 3. Verify the Platform Is Live
```bash
curl http://<ALB_DNS_NAME>/health
curl http://<ALB_DNS_NAME>/version
```
Expected:
`/health`→ 200 OK
`/version` → version identifier

### 4. Trigger an Automated Deployment

Any push to main automatically triggers the CI/CD pipeline.
```bash
git commit --allow-empty -m "Trigger deployment"
git push
```

### 5. Monitor Deployment

GitHub → Actions → Deploy (ECS Blue/Green)
AWS Console → CodeDeploy → Deployments

After completion:
```bash
curl http://<ALB_DNS_NAME>/version
```
A new commit SHA confirms a successful deployment.

---

## 🔁 CI/CD Pipeline (GitHub Actions)

### Trigger
- Any push to the `main` branch

### Pipeline Steps
1. Authenticate to AWS using **OIDC** (no AWS secrets stored in GitHub)
2. Build Docker image
3. Tag image with **Git commit SHA**
4. Push image to **Amazon ECR**
5. Register a new **ECS task definition revision**
6. Generate & upload **AppSpec** to S3
7. Trigger **CodeDeploy Blue/Green deployment**
8. Wait for deployment completion
9. Run **smoke tests** against the ALB endpoint

---

## 🔄 Blue/Green Deployment Strategy

- Two target groups: **Blue (current)** and **Green (replacement)**
- Deployment config:  
  `CodeDeployDefault.ECSCanary10Percent5Minutes`
- Traffic is shifted gradually after health checks pass
- Old task set is terminated only after success

This ensures **zero downtime** and safe rollbacks.

---

## ♻️ Automatic Rollback Demonstration

To validate platform resilience, an intentional failure was introduced:

- A deployment was pushed with a failing `/health` endpoint
- Replacement task set never became healthy
- **CodeDeploy detected failure and automatically rolled back**
- Production traffic remained uninterrupted

This confirms:
- Health checks are enforced
- Traffic is protected
- Rollbacks are fully automated

---

## 🔐 Security Design

- **No long-lived AWS credentials**
- GitHub Actions authenticates using **OIDC**
- IAM roles follow **least-privilege**
- Terraform state stored securely in **S3 with encryption**
- State locking enforced with **DynamoDB**

---

## 💰 Cost Guardrails

- AWS Budget configured with alerts (80% / 100%)
- All infrastructure is fully destroyable via Terraform
- Explicit teardown scripts included

---

## 🧹 Teardown & Cleanup

To destroy application infrastructure:

```bash
./scripts/destroy.sh
```
