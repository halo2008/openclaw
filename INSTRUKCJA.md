# Instrukcja wdrożenia OpenClaw

## Co potrzebujesz przed startem

- [ ] Konto Hetzner Cloud + API token
- [ ] Konto Cloudflare z domeną `ks-infra.dev`
- [ ] Terraform >= 1.5 zainstalowany
- [ ] gcloud CLI zalogowany (`gcloud auth login`)
- [ ] Klucz SSH w `~/.ssh/id_ed25519`

## Krok 1 — Hetzner API token

1. Zaloguj się na https://console.hetzner.cloud
2. Utwórz nowy projekt (lub użyj istniejącego)
3. Przejdź do **Security** → **API Tokens** → **Generate API Token**
4. Nadaj uprawnienia **Read & Write**
5. Skopiuj token — zobaczysz go tylko raz

## Krok 2 — Cloudflare API token i ID

### Account ID i Zone ID

1. Zaloguj się na https://dash.cloudflare.com
2. **Account ID** — widoczny w prawym panelu na stronie głównej
3. Kliknij domenę `ks-infra.dev`
4. **Zone ID** — prawy panel, sekcja "API"

### API Token

1. Przejdź do https://dash.cloudflare.com/profile/api-tokens
2. **Create Token** → **Custom token**
3. Ustaw uprawnienia:

| Zasób | Uprawnienie |
|-------|-------------|
| Zone > DNS | Edit |
| Account > Cloudflare Tunnel | Edit |
| Zone > Zone | Read |

4. Ogranicz do strefy `ks-infra.dev`
5. Skopiuj token

## Krok 3 — Bucket na state Terraforma

Jednorazowo — tworzysz GCS bucket na zdalny state:

```bash
gsutil mb -p festive-dolphin-483819-i1 -l EU gs://openclaw-tfstate
gsutil versioning set on gs://openclaw-tfstate
```

## Krok 4 — Konfiguracja zmiennych

```bash
cd ~/code/openclaw-infra
cp terraform.tfvars.example terraform.tfvars
```

Uzupełnij `terraform.tfvars`:

```hcl
hcloud_token          = "token-z-hetzner"
cloudflare_api_token  = "token-z-cloudflare"
cloudflare_account_id = "account-id-z-dashboardu"
cloudflare_zone_id    = "zone-id-z-dashboardu"
gcp_project_id        = "festive-dolphin-483819-i1"
domain                = "claw.ks-infra.dev"
environment           = "prod"
location              = "nbg1"
server_type           = "cx22"
ssh_public_key_path   = "~/.ssh/id_ed25519.pub"
ssh_port              = 2222
ssh_user              = "deploy"
allowed_ssh_ips       = ["TWOJE.IP/32"]
```

Żeby sprawdzić swoje publiczne IP:

```bash
curl -s ifconfig.me
```

## Krok 5 — Deploy

```bash
terraform init
terraform plan        # sprawdź co się stworzy
terraform apply       # potwierdź "yes"
```

Terraform stworzy:
- Serwer CX22 na Hetznerze (Ubuntu 24.04)
- Użytkownik `deploy` (bez root SSH)
- SSH na porcie 2222 (zamiast domyślnego 22)
- VPC + subnet
- Firewall (tylko port 2222 + ICMP)
- Cloudflare Tunnel + DNS `claw.ks-infra.dev`
- GCS bucket na state

## Krok 6 — Weryfikacja

```bash
# SSH na serwer (niestandardowy port + user deploy)
ssh -p 2222 deploy@$(terraform output -raw server_ipv4)

# Sprawdź czy cloudflared działa
sudo systemctl status cloudflared

# Sprawdź Dockera
docker ps

# Sprawdź tunel z przeglądarki
curl https://claw.ks-infra.dev
```

> **Uwaga:** Root login jest wyłączony. Łączysz się zawsze jako `deploy`.
> Użytkownik `deploy` ma sudo bez hasła i dostęp do Dockera.

## Koszty

| Zasób | Koszt miesięczny |
|-------|-----------------|
| Hetzner CX22 (2 vCPU, 4 GB RAM) | ~€4.35 |
| Cloudflare Tunnel | darmowy |
| GCS bucket (state) | ~$0 |
| **Razem** | **~€4.35/mies** |

## Jak to działa

```
Użytkownik → claw.ks-infra.dev → Cloudflare CDN → Tunel → cloudflared → localhost:8080
```

- Serwer nie ma otwartych portów 80/443 — cały ruch HTTP idzie przez tunel
- SSH na porcie 2222 — omija automaty skanujące port 22
- Root login wyłączony — tylko user `deploy` z kluczem SSH
- Hasła wyłączone — tylko klucz publiczny
- fail2ban banuje IP po 3 nieudanych próbach na 1h
- State Terraforma bezpiecznie w GCS z wersjonowaniem

## Przydatne komendy

```bash
# Podgląd outputów
terraform output

# SSH (dodaj do ~/.ssh/config żeby nie wpisywać portu za każdym razem)
# Host openclaw
#   HostName <IP>
#   User deploy
#   Port 2222
#   IdentityFile ~/.ssh/id_ed25519

# Zniszczenie infrastruktury (uwaga!)
terraform destroy

# Przebudowa serwera (np. po zmianie cloud-init)
terraform taint module.server.hcloud_server.main
terraform apply
```

## Rozwiązywanie problemów

### Nie mogę się połączyć po SSH

1. Sprawdź czy używasz portu 2222: `ssh -p 2222 deploy@IP`
2. Sprawdź czy Twoje IP jest w `allowed_ssh_ips` (mogło się zmienić)
3. Zaktualizuj IP w `terraform.tfvars` i `terraform apply`

### cloudflared nie działa

```bash
ssh -p 2222 deploy@IP
sudo journalctl -u cloudflared -f
```

### Chcę zmienić port SSH

Zmień `ssh_port` w `terraform.tfvars` i przebuduj serwer:

```bash
terraform taint module.server.hcloud_server.main
terraform apply
```
