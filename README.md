# Octa Byte AI – DevOps Assignment

This project demonstrates a complete CI/CD setup for deploying a React-vite application using Jenkins, PM2, and GitHub, along with Terraform-based infrastructure provisioning on AWS.

---

## 🧱 Project Components

### 1. Infrastructure Provisioning (Terraform) - http://byte-lb-868216908.us-east-1.elb.amazonaws.com/

- AWS VPC with public/private subnets
- EC2 instances
- RDS PostgreSQL (non-HA)
- Application Load Balancer (ALB)
- Security Groups, Key Pairs

I have created two EC2 instances, installed all the required software, deployed our React application, and configured it with a Load Balancer.

This is your Load Balancer DNS: http://byte-lb-868216908.us-east-1.elb.amazonaws.com/. You can use this URL to access the deployed application.


### 2. CI/CD Pipeline (Jenkins)- http://3.90.220.66:8080/
- Clones code from GitHub
- Installs react-js dependencies (`npm install`)
- Optional build step (`npm run build`)
- Deploys to remote EC2 using `ssh` and `pm2`
- Automatically restarts the app

### 2. Monitoring Tools (Grafana)- http://54.85.52.73:3001/
- To ensure observability of the deployed infrastructure and application, the following monitoring tools were configured:
- Prometheus: Used for collecting metrics from EC2 instances, application services, and the system. Exporters like node_exporter were used to expose CPU, memory, disk, and network metrics.
- Grafana: Used to visualize the metrics collected by Prometheus. Custom dashboards were created to monitor:
- Infrastructure performance (CPU, memory, disk usage)

- Application health (request rate, error rate, latency)

---

## 🚀 Tools Used

| Tool        | Purpose                          |
|-------------|----------------------------------|
| **Terraform** | Provision AWS infrastructure     |
| **Jenkins**   | Automate CI/CD pipeline          |
| **GitHub**    | Source code repository           |
| **PM2**       | Node.js process management       |
| **Nginx**     | (Optional) Reverse proxy/static hosting |
| **PostgreSQL**| Database (via AWS RDS)           |
| **Application Load Balancer (ALB)** | Traffic routing |


---

## 🛠️ Setup Instructions

### 1. Infrastructure

```bash
cd terraform/
terraform init
terraform apply
terraform destroy

```
### 2. Deploye Application

```bash
pm2 status 
pm2 apply 
pm2 delete 
 ```

 ### 📌 Final Output

 - Jenkins auto-fetches code from GitHub

 - Installs and builds on the Jenkins node
 - SSHs into EC2 and deploys app via pm2
 - App runs at: http://byte-lb-868216908.us-east-1.elb.amazonaws.com/
 

### 🛡️ Security Notes
 - GitHub credentials are stored securely in Jenkins

 - EC2 access is via SSH key, stored securely in Jenkins
 - Never commit secrets or private keys to GitHub


### 🙋 Author
 Ashis Kumar Nahak
-DevOps Developer 

