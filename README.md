# 🦅 Redhawk - Server Defense System

**Production-grade server bootstrap & security hardening tool**

<div align="center">
  <img src="/home/__juanabelly__/.gemini/antigravity/brain/482f311d-93e5-4282-acd4-21ecc6477bd1/redhawk_logo_v2_1765637828316.png" alt="Redhawk Logo" width="300">
</div>

Redhawk automates the setup and security hardening of Ubuntu/Debian servers using Ansible.

---

## ✨ Features

### 📦 Application Stack
- Docker & Docker Compose
- Portainer (Container Management)
- Nginx Proxy Manager
- Traefik (Reverse Proxy)
- Uptime Kuma (Monitoring)

### 🔒 Security Suite
- UFW Firewall (auto-configured)
- ClamAV Antivirus
- SSH Hardening
- Port Scanning (nmap)
- Vulnerability Scanning (Lynis with 1-10 risk scoring)

---

## 🚀 Quick Install
```bash
curl -fsSL https://raw.githubusercontent.com/juanabely/redhawk/main/install-redhawk.sh | sudo bash
```

Then run:
```bash
redhawk
```

---

## 📋 Requirements

- Ubuntu 22.04+ / Debian 11+
- Root or sudo access
- 2GB RAM minimum
- Internet connection

---

## 🎯 Usage
```bash
redhawk
```

### Menu Options:
1. **Application Setup** - Install Docker, Portainer, NPM, Traefik, Uptime Kuma
2. **Security Setup** - Configure firewall, antivirus, SSH hardening
3. **Security Audit** - Scan ports, check vulnerabilities with risk scoring

---

## 🛡️ Security Features

- **UFW Firewall**: Auto-allows SSH (22), HTTP (80), HTTPS (443), Portainer (9000/9443)
- **ClamAV**: Automated virus scanning
- **SSH Hardening**: Disables root login, password auth
- **Port Scanning**: Identifies open ports
- **Vulnerability Scoring**: 1-10 risk scale with actionable warnings

---

## 🧪 Testing

### Test on a fresh VM:
```bash
# Install Redhawk
curl -fsSL https://raw.githubusercontent.com/juanabely/redhawk/main/install-redhawk.sh | sudo bash

# Run setup
redhawk

# Test Docker
docker --version

# Test Portainer
curl http://localhost:9000

# Run security audit
redhawk → [3] Security Audit → [3] Full Audit
```

---

## 🔧 Advanced Usage

### Run playbooks directly:
```bash
# Install everything
ansible-playbook /opt/redhawk/playbooks/apps.yml

# Security hardening only
ansible-playbook /opt/redhawk/playbooks/security.yml

# Scan only
ansible-playbook /opt/redhawk/playbooks/scan.yml
```

### Install specific components:
```bash
# Docker only
ansible-playbook /opt/redhawk/playbooks/apps.yml --tags docker

# Firewall only
ansible-playbook /opt/redhawk/playbooks/security.yml --tags ufw
```

---

## 📁 Project Structure
```
redhawk/
├── install-redhawk.sh      # Installer
├── redhawk.sh              # Main CLI
├── menus/                  # Menu scripts
├── playbooks/              # Ansible playbooks
├── roles/                  # Ansible roles
└── inventory/              # Host configuration
```

---

## 🚧 Roadmap

- [ ] Remote host support (multi-server)
- [ ] Web UI dashboard
- [ ] Custom firewall rules
- [ ] Automated backups
- [ ] Log aggregation
- [ ] Fail2ban integration

---

## 📄 License

MIT

---

## 🤝 Contributing

PRs welcome! Please test on a fresh Ubuntu 22.04 VM before submitting.

---

**Built with ❤️ for DevOps and Security Engineers by Juanabely**