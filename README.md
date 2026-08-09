# 🚀 Highly Available 3-Tier AWS Web Architecture

A production-inspired **highly available, scalable, secure, and fault-tolerant 3-tier web architecture** built on **Amazon Web Services (AWS)**.

This project demonstrates the design and deployment of a multi-AZ AWS infrastructure using **Amazon VPC, EC2, Application Load Balancer, Amazon RDS, Amazon S3, and IAM**.

The architecture separates the application into distinct tiers, applies **least-privilege security controls**, and uses AWS managed services to improve availability, scalability, and operational reliability.

---

## 📌 Project Overview

The goal of this project is to build a production-inspired AWS environment capable of handling traffic across multiple Availability Zones while keeping the database layer isolated from direct internet access.

The architecture includes:

* 🌐 **Public Web Tier** – Application Load Balancer and EC2 web servers
* 🔒 **Private Database Tier** – Amazon RDS MySQL
* 🪣 **Decoupled Storage** – Private Amazon S3 bucket for application/static assets
* 🛡️ **Network Security** – VPC, Security Groups, private subnets, and controlled traffic flow
* 🔐 **IAM-Based Access** – EC2 IAM Role instead of hardcoded AWS credentials
* ♻️ **High Availability** – Resources distributed across two Availability Zones

---

## 🏗️ Architecture

The infrastructure is deployed across two Availability Zones:

```text
                         INTERNET
                             │
                             ▼
                    ┌─────────────────┐
                    │ Internet Gateway│
                    └────────┬────────┘
                             │
                             ▼
                 ┌────────────────────────┐
                 │ Application Load       │
                 │ Balancer (ALB)         │
                 │      Public Subnets    │
                 └───────────┬────────────┘
                             │
                 ┌───────────┴───────────┐
                 ▼                       ▼
        ┌─────────────────┐     ┌─────────────────┐
        │ Availability    │     │ Availability    │
        │ Zone 1          │     │ Zone 2          │
        │                 │     │                 │
        │ EC2 Web Server  │     │ EC2 Web Server  │
        │ + Nginx         │     │ + Nginx         │
        └────────┬────────┘     └────────┬────────┘
                 │                       │
                 └───────────┬───────────┘
                             │
                             │ MySQL : 3306
                             ▼
                  ┌──────────────────────┐
                  │   Amazon RDS MySQL   │
                  │   Private Subnets    │
                  └──────────────────────┘


             EC2 IAM Role
                  │
                  ▼
          ┌─────────────────┐
          │ Private S3      │
          │ Bucket          │
          │ Static Assets   │
          └─────────────────┘
```

### Architecture Diagram

---

## 🛠️ AWS Services & Technology Stack

| Service / Technology          | Purpose                                                        |
| ----------------------------- | -------------------------------------------------------------- |
| **Amazon VPC**                | Custom network isolation and subnet architecture               |
| **Application Load Balancer** | Distributes incoming HTTP traffic across healthy EC2 instances |
| **Amazon EC2**                | Hosts the web/application layer                                |
| **Ubuntu 22.04 LTS**          | Operating system for EC2 instances                             |
| **Nginx**                     | Web server                                                     |
| **Amazon RDS MySQL**          | Managed relational database                                    |
| **Amazon S3**                 | Private storage for static/application assets                  |
| **AWS IAM**                   | Identity and access management                                 |
| **Security Groups**           | Stateful network-level access control                          |
| **Internet Gateway**          | Provides internet connectivity for public subnets              |

---

## ✨ Key Features

### ♻️ High Availability

* Infrastructure distributed across **two Availability Zones**
* Multiple EC2 web servers behind an Application Load Balancer
* ALB health checks detect unhealthy instances
* Traffic is automatically routed only to healthy targets

### 🔐 Security & Least Privilege

* RDS is deployed in **private subnets**
* Database does not require direct internet exposure
* Security Groups allow only required traffic
* MySQL access is restricted to the **Web Server Security Group**
* EC2 accesses S3 through an **IAM Role**
* No AWS access keys are stored on the EC2 instances

### 📦 Stateless Web Tier

The EC2 web servers are designed to remain as stateless as possible.

Application/static assets are stored separately in S3, allowing the web instances to retrieve required files without relying on local persistent storage.

### 📈 Scalability

The architecture provides a foundation for horizontal scaling by allowing additional EC2 instances to be added behind the Application Load Balancer.

### 🗄️ Private Database Tier

Amazon RDS MySQL is isolated from direct internet traffic and can only be accessed by authorized resources through controlled Security Group rules.

---

# 🔄 Application Workflows

## 1️⃣ User Traffic Flow

Users access the application through the Application Load Balancer.

The ALB performs health checks on the EC2 targets and distributes requests across healthy instances.

```text
User
 │
 ▼
Internet Gateway
 │
 ▼
Application Load Balancer
 │
 ├───────────────┐
 ▼               ▼
EC2 Web Server 1  EC2 Web Server 2
 │               │
 └───────┬───────┘
         ▼
      Nginx
```

---

## 2️⃣ Secure Database Flow

When the application requires database access, the EC2 web servers connect to the RDS MySQL instance over port `3306`.

The RDS Security Group allows inbound MySQL traffic only from the Web Server Security Group.

```text
EC2 Web Server 1 ─────┐
                      │
                      │ TCP : 3306
                      ▼
               RDS Security Group
                      │
                      ▼
               Amazon RDS MySQL
                 Private Subnet
```

This avoids exposing MySQL directly to the public internet.

---

## 3️⃣ S3 Asset Retrieval Flow

EC2 instances use an attached IAM Role to securely retrieve files from the private S3 bucket.

No static AWS credentials are stored on the server.

```text
        EC2 Instance
             │
             │ IAM Role
             ▼
        AWS CLI / API
             │
             │
             ▼
       Private S3 Bucket
             │
             ▼
      Application Assets
```

Example:

```bash
aws s3 cp s3://<bucket-name>/ <destination> --recursive
```

---

# ☁️ AWS Infrastructure

The environment is deployed inside a custom VPC spanning two Availability Zones:

* `us-east-1a`
* `us-east-1b`

### Network Components

| Component                     | Network Placement | Purpose                                    |
| ----------------------------- | ----------------- | ------------------------------------------ |
| **Application Load Balancer** | Public Subnets    | Internet-facing traffic entry point        |
| **EC2 Web Servers**           | Public Subnets    | Hosts the Nginx web/application layer      |
| **Amazon RDS MySQL**          | Private Subnets   | Secure database tier                       |
| **Internet Gateway**          | VPC Edge          | Internet connectivity for public resources |
| **Security Groups**           | VPC               | Controls inbound and outbound traffic      |

---

## 🔒 Security Group Traffic Flow

The architecture follows a **Security Group-to-Security Group access model** wherever possible.

```text
Internet
   │
   │ TCP : 80
   ▼
ALB-SG
   │
   │ TCP : 80
   ▼
Web-Server-SG
   │
   │ TCP : 3306
   ▼
RDS-Database-SG
```

### Network Ports

|   Port | Protocol | Traffic Flow    | Purpose                       |
| -----: | -------- | --------------- | ----------------------------- |
|   `80` | HTTP     | Internet → ALB  | Web traffic                   |
|   `80` | HTTP     | ALB → EC2       | Forwarded application traffic |
|   `22` | SSH      | Admin IP → EC2  | Administrative access         |
| `3306` | MySQL    | Web-SG → RDS-SG | Database connectivity         |

> 🔐 **Security Note:** SSH access should be restricted to a trusted administrator IP rather than `0.0.0.0/0`.

---

# 🪣 Amazon S3

A private S3 bucket is used to store application/static assets separately from the EC2 instances.

### Benefits

* Decouples application assets from compute
* Reduces dependency on local EC2 storage
* Enables centralized asset management
* Allows EC2 instances to retrieve files through IAM permissions
* Keeps the bucket private

Example command:

```bash
aws s3 ls s3://<bucket-name>/
```

---

# 🗄️ Amazon RDS MySQL

The database tier uses **Amazon RDS for MySQL**.

### Security Design

* RDS deployed in private subnets
* No direct public access
* Database access restricted through Security Groups
* Only the Web Server Security Group can initiate MySQL connections
* Database traffic uses TCP port `3306`

---

# 📸 Project Validation

Validation screenshots are available in the `screenshots/` directory.

The screenshots demonstrate:

1. **VPC Resource Map** – Custom network topology
2. **RDS Security Group Rules** – Restricted database access
3. **S3 Bucket Objects** – Decoupled application assets
4. **EC2 IAM Role & S3 CLI Pull** – Credential-free S3 access
5. **RDS MySQL Connection** – Private database connectivity

---

# 📂 Repository Structure

```text
aws-3tier-architecture-poc/
│
├── README.md
│
├── architecture/
│   └── architecture-diagram.png
│
├── scripts/
│   └── ec2-user-data.sh
│
├── docs/
│   └── AWS_3_Tier_Architecture_Documentation.pdf
│
└── screenshots/
    ├── 01-vpc-resource-map.png
    ├── 02-rds-security-group-rules.png
    ├── 03-s3-bucket-objects.png
    ├── 04-ec2-s3-cli-pull.png
    └── 05-rds-mysql-connection.png
```

---

# 🎯 What I Learned

Through this project, I gained hands-on experience with:

* Designing a **3-tier architecture on AWS**
* Creating and configuring a custom **VPC**
* Working with **public and private subnets**
* Deploying EC2 instances across multiple Availability Zones
* Configuring an **Application Load Balancer**
* Creating ALB target groups and health checks
* Deploying **Amazon RDS MySQL**
* Implementing **Security Group-to-Security Group access**
* Using **IAM Roles** for EC2-to-S3 access
* Working with private S3 buckets
* Troubleshooting network and connectivity issues
* Validating AWS infrastructure through the AWS Console and CLI

---

# 🚀 Future Improvements

The current implementation provides a strong foundation for a production-inspired AWS architecture. Possible improvements include:

* [ ] Add **Auto Scaling Group** for EC2 instances
* [ ] Add **NAT Gateway** for private subnet outbound connectivity
* [ ] Enable **HTTPS** using AWS Certificate Manager (ACM)
* [ ] Add **Route 53** for DNS management
* [ ] Enable **RDS Multi-AZ** deployment
* [ ] Add **CloudWatch monitoring and alarms**
* [ ] Implement infrastructure as code using **Terraform**
* [ ] Add CI/CD using **Jenkins or GitHub Actions**
* [ ] Add centralized logging and monitoring
* [ ] Implement automated deployment pipelines

---

# 👨‍💻 Author

## Amit Sharma

**DevOps Engineer | AWS Certified Solutions Architect – Associate**

### Connect With Me

* 💼 **LinkedIn:** [linkedin.com/in/amitsharma2003](https://linkedin.com/in/amitsharma2003/)
* 🐙 **GitHub:** [github.com/amitsharma-2003](https://github.com/amitsharma-2003/)

---

⭐ **If you found this project useful, consider giving the repository a star!                                                                     **
