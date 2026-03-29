<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openclaw-wordmark-dark.svg">
        <img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openclaw-wordmark-light.svg" alt="OpenClaw" width="400">
    </picture>
</p>

<p align="center">
  <strong>The Lobster Way. 🦞</strong>
</p>

# 🚀 OpenClaw Infrastructure

> 🌐 **[Po polsku? Przeczytaj instrukcję (INSTRUKCJA.md)](file:///home/konrad-s-dkowski/code/openclaw/INSTRUKCJA.md)**

<p align="center">

  [![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/)
  [![Hetzner](https://img.shields.io/badge/Hetzner-Cloud-ff0000?style=for-the-badge&logo=hetzner)](https://www.hetzner.com/cloud)
  [![GCP](https://img.shields.io/badge/GCP-State-4285F4?style=for-the-badge&logo=google-cloud)](https://cloud.google.com/)
  [![Cloudflare](https://img.shields.io/badge/Cloudflare-Tunnel-F38020?style=for-the-badge&logo=cloudflare)](https://www.cloudflare.com/)
  [![n8n](https://img.shields.io/badge/n8n-Automation-FF6D5B?style=for-the-badge&logo=n8n)](https://n8n.io/)
  [![Qdrant](https://img.shields.io/badge/Qdrant-Knowledge-00D2FF?style=for-the-badge&logo=qdrant)](https://qdrant.tech/)
  [![Firebase](https://img.shields.io/badge/Firebase-Notifications-FFCA28?style=for-the-badge&logo=firebase)](https://firebase.google.com/)
  [![ClawBot](https://img.shields.io/badge/ClawBot-Framework-FF4F4F?style=for-the-badge)](https://github.com/halo2008/openclaw)
</p>

Automated, production-ready infrastructure for **OpenClaw** hosted on Hetzner Cloud. Features secure access via Cloudflare Tunnels and a remote GCP state backend.

---

## 🏗️ Architecture

```mermaid
graph TD
    User((User)) -->|HTTPS| CF[Cloudflare CDN]
    CF -->|Encrypted Tunnel| CT[cloudflared]
    
    subgraph "Hetzner Cloud (K3s Cluster)"
        direction TB
        CT -->|Local Ingress| K8S[K3s / Traefik]
        
        K8S --> App[OpenClaw Bot]
        K8S --> n8n[n8n Automation]
        
        App -.- Tools[Agent Tools & Knowledge]
        App --> Cron[Cron Scheduler]
        
        Tools --> KB[(Qdrant DB)]
        Tools --> Search[Web Search]
        Tools --> FCM[FCM Push Service]
        
        subgraph "Monitoring Layer"
            Alloy[Grafana Alloy] --> Prometheus[Prometheus Agent]
            Alloy --> Loki[Loki Push]
        end
        
        K8S -.-> Alloy
    end
    
    Prometheus --> GC[Grafana Cloud]
    Loki --> GC
    
    Terraform[Terraform CLI] -->|Remote State| GCS[(GCP Bucket)]
    Terraform -->|Manage| Hetzner
```

> [!NOTE]
> All incoming web traffic is routed through **Cloudflare Tunnel** and managed by **K3s / Traefik ingress**. The server has NO public HTTP/S ports open to the internet.

---

## 📦 Infrastructure Stack

| Component | Description |
|-----------|-------------|
| **Compute** | Hetzner CX33 (4 vCPU, 8 GB RAM) |
| **Orchestration** | **K3s (Lightweight Kubernetes)** |
| **Networking** | Private VPC (`10.0.0.0/16`) with internal subnets |
| **Security** | SSH on port 2222, Fail2Ban, root access disabled |
| **Connectivity** | Cloudflare Tunnel (no public ingress) |
| **Monitoring** | **Grafana Cloud (Prometheus + Loki via Alloy)** |
| **State** | GCS bucket with versioning for Terraform state |

---

## 🛠️ Prerequisites

Before you begin, ensure you have:

- [ ] **Terraform** >= 1.5 installed
- [ ] **gcloud CLI** authenticated (`gcloud auth login`)
- [ ] **Hetzner Cloud** account + API token
- [ ] **Cloudflare** account with DNS zone managed
- [ ] **SSH Key** available at `~/.ssh/id_ed25519`

---

## 🚀 Getting Started

### 1️⃣ Initialize remote state
Create a GCS bucket to store your infrastructure state securely:
```bash
gsutil mb -p your-project-id -l EU gs://openclaw-tfstate
gsutil versioning set on gs://openclaw-tfstate
```

### 2️⃣ Configure environment
Clone the example configuration and fill in your details:
```bash
cp terraform.tfvars.example terraform.tfvars
# Open terraform.tfvars and provide your keys/IDs
```

### 3️⃣ Deploy infrastructure
```bash
terraform init
terraform plan
terraform apply
```

---

## 🛡️ Security Model

Designed with a **Zero Trust** mindset:

- 🔒 **Zero Public Ingress**: No ports 80/443 exposed. All web traffic flows through the tunnel.
- 🛂 **Cloudflare Access**: The OpenClaw UI is protected by **Zero Trust Access policies**, requiring email-based authentication (OTP) before reaching the application.
- 🔑 **Hardened SSH**:
  - Custom port `2222` to avoid scanners.
  - Root login **disabled**.
  - Password authentication **disabled** (SSH key only).
  - Restricted to whitelisted IPs via firewall.
- 🛡️ **Active Protection**: `fail2ban` automatically drops IPs after multiple failed attempts.
- 📁 **Secure State**: Infra state is versioned and encrypted in GCS.

---

## 💰 Cost Breakdown (Monthly)

| Resource | Cost (Est.) |
|----------|-------------|
| Hetzner CX33 | **~€10.35** |
| Cloudflare Tunnel | **Free** |
| GCS State Storage | **Minimal** |
| **Total** | **~€10.35 / mo** |

---

## 📑 Module Overview

- `network`: VPC and internal subnet configuration.
- `firewall`: Custom SSH and ICMP rules.
- `cloudflare`: Tunnel and DNS record management.
- `server`: CX33 instance with `cloud-init` bootstrapping.

> [!TIP]
> **Remote state** is strongly recommended for production use. This project uses a GCS bucket with versioning as the Terraform backend — configured in `providers.tf`, not as a separate module. This ensures state is safely stored, versioned, and accessible from CI/CD runners (e.g. when using scheduled agents like Claude Code triggers). You can substitute GCS with any supported [Terraform backend](https://developer.hashicorp.com/terraform/language/backend) (S3, Azure Blob, etc.).

---

## 🔌 Ecosystem & Integrations

Enhance your OpenClaw setup with these optional components:

- **n8n**: Dedicated nodes are available for automating OpenClaw workflows. Expose it via `extra_hostnames` for secure access.
- **Qdrant**: High-performance vector database for your knowledge base.
- **FCM Push**: Built-in service for sending real-time notifications to the ClawAPK mobile app.
- **Cron Scheduler**: Automated task execution based on custom schedules.
- **Monitoring**: Full observability with Grafana Cloud, tracking metrics and logs in real-time.
- **LLM Providers**: Support for Google Gemini, DeepSeek, Groq, SambaNova, and Cerebras.

---

## 🚦 Verification Commands

```bash
# SSH Access (Non-root, port 2222)
ssh -p 2222 deploy@$(terraform output -raw server_ipv4)

# Service Health
sudo systemctl status cloudflared
docker ps

# External Health Check
curl -I https://your-domain.com
```
