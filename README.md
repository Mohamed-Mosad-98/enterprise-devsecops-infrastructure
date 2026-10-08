# DevSecOps Platform on Amazon EKS

A production-oriented DevSecOps platform deployed on **Amazon EKS**, designed to demonstrate infrastructure automation, container orchestration, application deployment, security, monitoring, DNS management, and disaster recovery.

---

## 📌 Project Overview

This project demonstrates the deployment and operation of a containerized **vProfile application** on Amazon EKS using modern DevOps and DevSecOps practices.

The platform covers the complete lifecycle:

**Infrastructure → Application Deployment → Security → Monitoring → DNS → Backup → Restore → Disaster Recovery**

The infrastructure and platform components are designed to provide a scalable, observable, and recoverable Kubernetes environment.

---

## 🏗️ Architecture

### Architecture Diagram

> **Add your Architecture Diagram here**

<!--
![Architecture Diagram](docs/images/architecture.png)
-->

**Recommended diagram flow:**

```text
                         AWS Cloud
                            |
                    +-------+-------+
                    |      VPC      |
                    |               |
              Public Subnets   Private Subnets
                    |               |
               Load Balancer     EKS Cluster
                                    |
                    +---------------+---------------+
                    |               |               |
                 vProfile        Monitoring       Platform
                    |               |               |
          +---------+---------+   Prometheus      Velero
          |         |         |   Grafana         Vault
        Nginx      App      Services             External-DNS
                    |
          +---------+---------+
          |         |         |
       MariaDB   RabbitMQ  Memcached
          |
       EBS/PVC
          |
       Snapshots
          |
      S3 / Velero
```

---

# ☁️ Infrastructure

The infrastructure is deployed on **AWS** with Amazon EKS as the Kubernetes control plane.

### Main AWS Components

* Amazon EKS
* Amazon VPC
* Public and Private Subnets
* EC2 Worker Nodes
* IAM
* Security Groups
* Amazon EBS
* EBS CSI Driver
* EKS Pod Identity
* Amazon S3
* Elastic Load Balancing

### Kubernetes Cluster

```text
Cluster: efe-capstone-eks
Region:  eu-north-1
Kubernetes: v1.36.2
```

The worker nodes run the application workloads and Kubernetes platform components.

---

# ⚙️ Infrastructure as Code

Terraform is used to automate the AWS infrastructure and make the environment reproducible.

The infrastructure includes resources such as:

* VPC
* Subnets
* Route tables
* Security groups
* EKS cluster
* EKS node groups
* IAM configuration
* EBS CSI integration
* EKS Pod Identity

### Benefits

* Reproducible infrastructure
* Version-controlled configuration
* Reduced manual configuration
* Easier environment recreation
* Consistent deployments

---

# 🚀 Application Deployment

The project deploys the **vProfile application** as a multi-component containerized application.

## Application Components

### Nginx

Acts as the web-facing component and routes traffic to the application.

### vProfile Application

The main application workload running inside Kubernetes.

### MariaDB

Provides persistent relational database storage.

### Memcached

Used as an application caching layer.

### RabbitMQ

Provides messaging functionality between application components.

### HashiCorp Vault

Used for centralized secret management.

---

# ☸️ Kubernetes Resources

The application is deployed using Kubernetes resources including:

* Deployments
* StatefulSets
* Services
* ConfigMaps
* Secrets
* PersistentVolumeClaims
* PersistentVolumes
* NetworkPolicies

Stateful workloads such as the database and RabbitMQ use persistent storage through Kubernetes PVCs.

---

# 🔐 Security

Security is implemented at multiple layers.

## Network Security

AWS Security Groups and Kubernetes NetworkPolicies are used to control network communication.

NetworkPolicies provide segmentation between application components and restrict unnecessary traffic.

## Secrets Management

Sensitive application information is managed through Kubernetes Secrets and **HashiCorp Vault**.

Vault provides centralized secret management instead of keeping sensitive values directly inside application manifests.

## IAM

AWS IAM is used to control access to AWS resources.

The project also uses **EKS Pod Identity** to provide AWS permissions to Kubernetes workloads without embedding AWS credentials inside containers.

---

# 📊 Monitoring & Observability

The platform uses **kube-prometheus-stack** for Kubernetes monitoring and observability.

## Monitoring Components

* Prometheus
* Grafana
* Alertmanager
* Node Exporter
* kube-state-metrics
* Prometheus Operator

### Prometheus

Collects metrics from Kubernetes and infrastructure components.

### Grafana

Provides dashboards for visualizing:

* CPU usage
* Memory usage
* Pod status
* Node health
* Kubernetes resources
* Application infrastructure metrics

### Alertmanager

Handles Prometheus alerts and provides centralized alert management.

### Node Exporter

Collects hardware and operating-system metrics from Kubernetes nodes.

### kube-state-metrics

Exposes Kubernetes object state as Prometheus metrics.

---

## 📸 Monitoring Screenshots

> Add Grafana screenshots here.

<!--
![Grafana Dashboard](docs/images/grafana-dashboard.png)

![Prometheus](docs/images/prometheus.png)

![Alertmanager](docs/images/alertmanager.png)
-->

---

# 🌐 External DNS

The project uses **external-dns** to automate DNS record management for Kubernetes services.

Instead of manually creating DNS records whenever services change, external-dns can synchronize Kubernetes resources with the configured DNS provider.

---

# 💾 Backup & Disaster Recovery

Backup and disaster recovery are implemented using **Velero** with Amazon S3 and EBS snapshots.

## Velero Architecture

```text
Kubernetes Cluster
       |
     Velero
       |
       +------------------+
       |                  |
       v                  v
      S3              EBS Snapshots
 Backup Metadata       Persistent Data
```

The Velero backup storage location uses the following S3 bucket:

```text
vprofile-velero-test-903146277726
```

---

# 📦 Namespace Backup & Restore

A monitoring namespace backup was created and tested.

The restore process was validated by:

1. Creating a backup of the monitoring namespace.
2. Removing the original `monitoring` namespace.
3. Restoring the namespace using Velero.
4. Verifying that Kubernetes recreated the required resources.
5. Verifying that monitoring components returned to a healthy state.

The restored monitoring stack included:

* Prometheus
* Grafana
* Alertmanager
* Node Exporter
* kube-state-metrics
* Prometheus Operator

This validated that the monitoring environment can be recovered from a Velero backup.

---

# 🌎 Full Cluster Backup

A complete cluster backup was also created using Velero.

```bash
velero backup create full-cluster-backup
```

The backup included:

* Kubernetes namespaces
* Deployments
* StatefulSets
* DaemonSets
* Services
* ConfigMaps
* Secrets
* PVCs
* PVs
* CRDs
* ClusterRoles
* ClusterRoleBindings
* NetworkPolicies
* Monitoring resources
* Vault resources
* vProfile resources
* Velero resources
* Kubernetes nodes
* Other cluster-scoped resources

### Backup Result

```text
Backup: full-cluster-backup
Status: Completed
Items backed up: 782 / 782
Errors: 0
Warnings: 0
```

The backup also created successful EBS volume snapshots for persistent workloads.

---

# 🗄️ S3 Backup Verification

The Velero backup objects were verified inside the S3 bucket.

Example:

```bash
aws s3 ls s3://vprofile-velero-test-903146277726/backups/
```

Expected backup folders include:

```text
full-cluster-backup/
monitoring-backup/
vprofile-backup/
```

This confirms that Velero successfully stored backup data in Amazon S3.

---

# 🔄 Disaster Recovery Workflow

The disaster recovery strategy follows this workflow:

```text
Production EKS Cluster
          |
          v
      Velero Backup
          |
          +------> S3
          |
          +------> EBS Snapshots
          |
          v
   Cluster Failure
          |
          v
 Create New EKS Cluster
          |
          v
 Install Velero
          |
          v
 Connect to S3
          |
          v
 Restore Full Backup
          |
          v
 Application Recovery
```

The namespace-level restore has already been validated.

The final optional DR validation is restoring the complete `full-cluster-backup` into a completely new EKS cluster.

---

# 📁 Kubernetes Namespaces

The environment contains platform and application namespaces including:

```text
default
external-dns
kube-node-lease
kube-public
kube-system
monitoring
vault
velero
vprofile
vprofile-helm-test
```

---

# 🔧 Main Technologies

| Category                | Technologies                  |
| ----------------------- | ----------------------------- |
| Cloud                   | AWS                           |
| Container Orchestration | Amazon EKS                    |
| Infrastructure as Code  | Terraform                     |
| Containers              | Docker                        |
| Kubernetes              | Kubernetes                    |
| CI/CD                   | Jenkins / GitLab CI           |
| Application             | vProfile                      |
| Database                | MariaDB                       |
| Messaging               | RabbitMQ                      |
| Caching                 | Memcached                     |
| Secrets                 | HashiCorp Vault               |
| Monitoring              | Prometheus                    |
| Visualization           | Grafana                       |
| Alerting                | Alertmanager                  |
| DNS                     | external-dns                  |
| Backup                  | Velero                        |
| Object Storage          | Amazon S3                     |
| Persistent Storage      | Amazon EBS                    |
| AWS Identity            | IAM / EKS Pod Identity        |
| Security                | NetworkPolicies / IAM / Vault |
| Version Control         | Git / GitHub                  |

---

# 📸 Project Screenshots

## Architecture

> **Add Architecture Diagram here**

<!--
![Architecture](docs/images/architecture.png)
-->

---

## AWS Infrastructure

> **Add AWS / EKS screenshots here**

<!--
![EKS Cluster](docs/images/eks-cluster.png)
-->

---

## Application

> **Add application screenshots here**

<!--
![vProfile Application](docs/images/vprofile.png)
-->

---

## Kubernetes

> **Add Kubernetes screenshots here**

<!--
![Kubernetes Resources](docs/images/kubernetes.png)
-->

---

## Monitoring

> **Add Grafana / Prometheus screenshots here**

<!--
![Grafana Dashboard](docs/images/grafana.png)
-->

---

## Backup & Restore

> **Add Velero backup/restore screenshots here**

<!--
![Velero Backup](docs/images/velero-backup.png)
-->

---

# 🧪 Validation

The following areas were validated during the project:

### Application

* Kubernetes workloads deployed successfully
* Application components communicate through Kubernetes Services
* Stateful workloads use persistent storage

### Monitoring

* Prometheus deployed successfully
* Grafana deployed successfully
* Alertmanager deployed successfully
* Node Exporter deployed successfully
* kube-state-metrics deployed successfully

### Backup

* Namespace backup completed successfully
* Full cluster backup completed successfully
* Backup stored in Amazon S3
* EBS snapshots created successfully

### Restore

* Monitoring namespace was deleted
* Monitoring namespace was restored using Velero
* Monitoring components recovered successfully

---

# 🏆 Project Highlights

* Automated AWS infrastructure using Terraform
* Containerized application deployed on Amazon EKS
* Kubernetes-based microservice architecture
* Persistent storage using Amazon EBS
* Centralized secrets management using Vault
* Kubernetes network segmentation using NetworkPolicies
* Monitoring using Prometheus and Grafana
* Automated DNS management using external-dns
* AWS workload identity using EKS Pod Identity
* Kubernetes backup using Velero
* Amazon S3 backup storage
* EBS volume snapshots
* Tested namespace-level disaster recovery
* Full-cluster backup with **782/782 resources backed up successfully**

---

# 🔄 End-to-End Platform Flow

```text
                    Developer
                        |
                        v
                   Git / GitHub
                        |
                        v
                 CI/CD Pipeline
                        |
                        v
                  Docker Image
                        |
                        v
                    AWS ECR
                        |
                        v
                  Amazon EKS
                        |
        +---------------+---------------+
        |               |               |
        v               v               v
    vProfile        Monitoring       Platform
        |               |               |
        |          Prometheus         Vault
        |          Grafana            Velero
        |          Alertmanager       external-dns
        |
   +----+----+---------+---------+
   |         |         |         |
 Nginx     App     MariaDB   RabbitMQ
                       |
                      EBS
                       |
                 EBS Snapshots
                       |
                       v
                  Velero / S3
```

---

# 🎯 Project Objective

The main objective of this project is to demonstrate the ability to design, deploy, secure, monitor, and recover a production-oriented Kubernetes platform on AWS.

The project combines:

**Cloud Infrastructure + Kubernetes + DevOps + DevSecOps + Observability + Backup & Disaster Recovery**

---

# 👨‍💻 Author

**Mohamed Mosad Fahmy**

DevOps / Cloud Engineer

GitHub: [Mohamed-Mosad-98](https://github.com/Mohamed-Mosad-98)

LinkedIn: [Mohamed Mosad](https://www.linkedin.com/in/mohamed-mosad-516aa717b/)

---

## ⭐ Project Summary

> A complete DevSecOps platform running on Amazon EKS, with automated infrastructure, containerized application workloads, centralized secrets, Kubernetes monitoring, automated DNS management, and a tested backup and restore strategy using Velero, Amazon S3, and EBS snapshots.

