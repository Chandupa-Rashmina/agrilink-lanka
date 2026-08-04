# Production Server Requirements

Before deployment, prepare:

- Ubuntu or Debian VPS
- Minimum 2 vCPU, 4 GB RAM, 40 GB SSD
- Docker Engine and Docker Compose plugin
- Domain/subdomain pointing to the VPS
- HTTPS reverse proxy or managed TLS
- SSH key access
- Firewall allowing only SSH, HTTP and HTTPS
- Off-server backup destination

Required values:

- Public API domain
- VPS public IP
- SSH username
- Deployment directory
- PostgreSQL password
- Laravel `APP_KEY`
- Production Android signing credentials

Do not store secrets in Git.
