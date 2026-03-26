# OpenClaw Infrastructure

Terraform-managed infrastructure for OpenClaw on Hetzner Cloud with Cloudflare Tunnel and GCP state backend.

## Architecture

```
                    ┌──────────────────────────────┐
                    │        Cloudflare CDN         │
                    │   claw.ks-infra.dev (CNAME)   │
                    └──────────┬───────────────────┘
                               │ Tunnel (encrypted)
                               ▼
┌─────────────────────────────────────────────────────────┐
│  Hetzner CX22 — Ubuntu 24.04                           │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │ cloudflared │──│ Docker       │  │ fail2ban      │  │
│  │ (systemd)   │  │ :8080        │  │ UFW           │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
│                                                         │
│  User: deploy (no root SSH)    SSH: port 2222 only     │
│  VPC: 10.0.1.0/24             Firewall: SSH + ICMP     │
└─────────────────────────────────────────────────────────┘

State: GCS bucket (openclaw-tfstate) — versioned, EU region
```

## Modules

| Module | Description |
|--------|-------------|
| `gcs-backend` | GCS bucket for Terraform remote state with versioning |
| `network` | Hetzner VPC (`10.0.0.0/16`) and cloud subnet |
| `firewall` | Hetzner firewall — custom SSH port and ICMP only |
| `cloudflare` | Cloudflare Tunnel + CNAME DNS record for `claw.ks-infra.dev` |
| `server` | Hetzner CX22 with cloud-init provisioning |

## Cloud-init provisioning

The server is bootstrapped on first boot with:

- **Docker** + docker-compose v2
- **cloudflared** — Cloudflare Tunnel daemon (systemd service)
- **fail2ban** — brute-force protection on custom SSH port
- **UFW** — firewall allowing only custom SSH port
- **Non-root user** (`deploy`) with sudo and Docker access
- **SSH hardened** — root login disabled, password auth disabled, custom port
- `/opt/openclaw` — application directory

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) — authenticated
- Hetzner Cloud account + API token
- Cloudflare account with `ks-infra.dev` zone
- SSH key pair at `~/.ssh/id_ed25519`

### Cloudflare API token permissions

Create a custom API token with:

| Permission | Access |
|-----------|--------|
| Zone > DNS | Edit |
| Account > Cloudflare Tunnel | Edit |
| Zone > Zone | Read |

### Required IDs from Cloudflare

1. **Account ID** — Dashboard → right sidebar
2. **Zone ID** — Dashboard → `ks-infra.dev` → right sidebar under "API"

## Getting started

### 1. Create the GCS state bucket

```bash
gsutil mb -p festive-dolphin-483819-i1 -l EU gs://openclaw-tfstate
gsutil versioning set on gs://openclaw-tfstate
```

### 2. Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
hcloud_token          = "hetzner-api-token"
cloudflare_api_token  = "cloudflare-api-token"
cloudflare_account_id = "account-id-from-dashboard"
cloudflare_zone_id    = "zone-id-from-dashboard"
gcp_project_id        = "festive-dolphin-483819-i1"
domain                = "claw.ks-infra.dev"
environment           = "prod"
location              = "nbg1"
server_type           = "cx22"
ssh_public_key_path   = "~/.ssh/id_ed25519.pub"
ssh_port              = 2222
ssh_user              = "deploy"
allowed_ssh_ips       = ["YOUR.PUBLIC.IP/32"]
```

> Get your public IP: `curl -s ifconfig.me`

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Verify

```bash
# SSH into the server (custom port, non-root user)
ssh -p 2222 deploy@$(terraform output -raw server_ipv4)

# Check cloudflared status
sudo systemctl status cloudflared

# Check Docker
docker ps

# Test the tunnel
curl https://claw.ks-infra.dev
```

## Outputs

| Output | Description |
|--------|-------------|
| `server_ipv4` | Public IPv4 address (SSH access) |
| `server_ipv6` | Public IPv6 address |
| `server_private_ip` | Private IP within VPC |
| `app_url` | `https://claw.ks-infra.dev` |
| `tunnel_id` | Cloudflare Tunnel ID |
| `state_bucket` | GCS bucket name |

## Security model

- **No public HTTP/S ports** — all web traffic routed through Cloudflare Tunnel
- **No root SSH** — dedicated `deploy` user with key-only auth
- **Custom SSH port** (2222) — avoids automated scanners targeting port 22
- **Password authentication disabled** — key-only access
- **SSH restricted** to whitelisted IPs via Hetzner firewall + UFW
- **fail2ban** — bans IPs after 3 failed attempts (1h ban)
- **Cloudflare proxy** — hides server IP, provides DDoS protection and WAF
- **State encrypted** at rest in GCS with versioning (5 versions retained)

## Cost estimate

| Resource | Monthly cost |
|----------|-------------|
| Hetzner CX22 (2 vCPU, 4 GB) | ~€4.35 |
| Hetzner IPv4 | included |
| Cloudflare Tunnel | free |
| GCS state bucket | ~$0 (minimal storage) |
| **Total** | **~€4.35/mo** |
