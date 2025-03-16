## Terraform Learning Codes

### Overview
This repository contains automation scripts for machine creation and code deployment over AWS using Terraform.

### Features
- **Create EC2 Instances** - Provision multiple EC2 instances in a single command.
- **Create and Manage AWS AMIs** - Automate the creation of custom Amazon Machine Images (AMIs).
- **Security Group Management** - Define and configure security groups, whitelist IPs, and ensure secure communication between microservices.

### Technologies Used
- **Terraform** - Infrastructure as Code (IaC) tool to automate cloud infrastructure across multiple providers.
- **AWS** - Cloud platform used for hosting and deploying resources.

---

## Getting Started

### Prerequisites
- **Terraform Installed** – [Download Here](https://developer.hashicorp.com/terraform/downloads)
- **AWS Account** with IAM user credentials (Access Key & Secret Key).
- **AWS CLI Installed** (optional but recommended) – [Download Here](https://aws.amazon.com/cli/)

> **Note:** Ensure your AWS credentials are configured before running Terraform scripts.  
```bash
aws configure
```

### Installation
```bash
# Clone the repository
git clone https://github.com/AshutoshMishra7081/Terraform-Practice.git
cd Terraform-Practice
```

---

## Running Script
```bash
terraform init   # Initialize Terraform and download necessary providers
terraform plan   # Preview the changes before applying
terraform apply  # Deploy the infrastructure
terraform destroy # Destroy all resources (EC2 instances, security groups, etc.)
```

### Thank you for exploring my Terraform scripts! Hope you find them useful. 😊 If you learned something new, feel free to ⭐ the repository.
