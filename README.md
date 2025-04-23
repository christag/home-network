# Home Network Kubernetes Cluster: Automated Setup & Management

This repository provides a fully automated, reproducible setup for a home Kubernetes (k3s) cluster spanning multiple heterogeneous devices. It is designed for reliability, security, and ease of management, using a combination of preseeded Debian installs, Ansible automation, and GitOps workflows. 

## CURRENT STATUS ##
🚧 Under Construction 🚧

Like a geocities homepage in the mid 90s, this project is still currently under construction. Here's the plan:

| Phase | Status | 
| --- | --- |
| Planning | ✅ Complete |
| Storage/NFS Setup | ✅ Complete |
| Ansible Playbook Creation | 🚧 In Progress |
| Physical Host Setup/K3s Install | ⭕ To Do | 
| Networking and Reverse Proxy Setup | ⭕ To Do |
| LDAP and SSO Rollout + Migration | ⭕ To Do |
| Observability Stack and KPI Dashboards | ⭕ To Do |
| GPU Scheduling Policy Build and Test | ⭕ To Do |
| Migrate all Containers to K3s | ⭕ To Do |
| Testing of All Containers, Auth, SSO, VPN, etc. | ⭕ To Do |
| Update Documentation, Communication, and Close Project | ⭕ To Do |

## Why This Project?

Home labs often grow organically, leading to a mix of machines, ad-hoc Docker containers, and manual configuration. This project aims to bring cloud-native best practices—like GitOps, SSO, and automated failover—to a home environment, while accounting for the unique constraints and opportunities of consumer hardware (NAS, Pi, gaming PCs, laptops, Mac mini, etc.).

**Key design choices:**
- **Diverse hardware:** The cluster runs across x86, ARM, and even Apple Silicon, maximizing resource use and resilience.
- **Separation of storage and control plane:** The NAS is used only for NFS storage and USB-bound workloads, not as a k3s controller, to avoid downtime and vendor lock-in.
- **Automated, repeatable setup:** From bare metal to running k3s, every step is automated for consistency and disaster recovery.
- **GitOps-first:** All configuration and app deployment is managed via Git, enabling easy rollback and audit.
- **Centralized SSO and monitoring:** Traefik, Authelia, and Grafana/Loki provide secure, unified access and observability.

## Repository Structure

- **host_setup/**: Tools and configs for fully automated OS installs (preseed, ISOLINUX, etc.)
  - `controller_laptop/`: Automated Debian install for the k3s controller node (preseed, ISOLINUX config, instructions)
- **ansible/**: All Ansible automation for post-install configuration
  - `playbooks/`: Playbooks for k3s controller and agent setup
  - `group_vars/`, `host_vars/`: Per-group and per-host configuration (including secrets via Ansible Vault)
  - `inventory/`: Ansible inventory files
  - `ansible.cfg`: Ansible configuration
- **setup.sh**: Example manual setup script for a GPU-enabled agent node (for reference or adaptation)
- **project.md** (not included in repo): Original project plan and rationale
- **adjustment.md** (not included in repo): Rationale for moving the controller role off the NAS

## Unique Features & Rationale

- **No control plane on the NAS:** The NAS is reserved for storage and USB-bound workloads only. This avoids downtime and data risk from firmware updates, limited I/O, and vendor-locked k3s builds.
- **HA and diversity:** The control plane runs on a Pi 4 and a Debian laptop (or mini-PC), providing both ARM and x86 nodes for resilience and flexibility.
- **NFS-backed persistent volumes:** All persistent data is stored on the NAS via NFS, but the control plane is independent, so storage outages don't bring down the cluster.
- **Automated failover and upgrades:** MetalLB, Traefik, and Authelia provide seamless failover, SSO, and secure ingress. Flux CD enables GitOps-driven upgrades and rollbacks.
- **GPU-aware scheduling:** Nodes with GPUs (e.g., RTX 4080) are labeled and managed so AI workloads can be scheduled without interfering with gaming or desktop use.
- **Centralized logging and monitoring:** Loki, Promtail, and Grafana aggregate logs and metrics for all nodes and services.

## Quickstart: How to Use This Repository

### 1. Prepare Your Hardware
- At minimum: a NAS (for NFS), a Pi 4, a Debian laptop or mini-PC, and any additional nodes (e.g., GPU PC, Mac mini, etc.).
- Ensure the NAS is set up with NFS exports for persistent volumes.

### 2. Automated OS Install (for controller)
- Use the files in `host_setup/controller_laptop/` to create a bootable Debian installer with preseed and ISOLINUX config.
- Boot the controller laptop from this media. The install will:
  - Partition disks, create users, and install base packages
  - Set up Ansible and systemd services for post-install automation

### 3. Post-Install Configuration (all nodes)
- Use the Ansible playbooks in `ansible/playbooks/` to configure each node:
  - `controller_bootstrap.yml` for the controller node (sets up k3s server, networking, NFS, etc.)
  - Adapt or create playbooks for agent nodes (see `setup.sh` for manual steps to automate)
- Inventory and variables are managed in `ansible/inventory/`, `group_vars/`, and `host_vars/`.
- Secrets (e.g., WiFi PSK, k3s token) are managed via Ansible Vault.

### 4. Cluster Operation
- After setup, the cluster is managed via GitOps: all changes are made in this repo and automatically applied by Flux CD.
- SSO, ingress, and monitoring are pre-configured for secure, unified access.
- GPU workloads are scheduled intelligently to avoid interfering with desktop/gaming use.

## Best Practices & Recommendations
- **Do not run the k3s control plane on the NAS.** Use the Pi 4 and Debian laptop/mini-PC for HA and performance.
- **Keep all configuration in Git.** Use PRs and reviews for changes.
- **Test disaster recovery regularly.** Practice restoring from etcd and NFS backups.
- **Monitor resource usage and logs.** Use Grafana and Loki dashboards for visibility.
- **Document any manual steps or hardware quirks.**

## Contributing
While this project is intended for my personal setup and is reflective of a very personal situation, PRs and issues are still welcome! 

