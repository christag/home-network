# Controller Laptop Host Setup (MSI)

This folder contains resources to fully automate the installation and configuration of the MSI controller laptop as a k3s controller node using Debian, preseed, and Ansible.

## Folder Structure

- **debian_patcher.sh**  
  Script to automate patching a stock Debian ISO with the preseed and isolinux configuration for unattended installation.
- **preseed/controller.preseed**  
  Automated Debian installation configuration. Sets up disk, user, packages, and runs post-install automation directly via preseed's `late_command`.
- **isolinux/isolinux.cfg**  
  Bootloader configuration for the Debian installer. Adds a menu entry for automated install using the provided preseed file.

## What This Script Configures

This script automates the customization and setup of a Debian-based machine, preparing it as a Kubernetes (k3s) controller node with GPU support and essential system tools. Below is a breakdown of what it configures:

### 1. OS and User Setup

- Automates the Debian installation using a preseed file and Ansible.
- Partitions the disk using LVM with no swap.
- Creates a user named `docker` (UID 1004) with membership in the `sudo` and `docker` groups.
- Sets the system hostname based on Ansible inventory variables.

### 2. System Updates and Base Packages

- Performs a full system `dist-upgrade`.
- Installs essential packages: `build-essential`, `curl`, `git`, `vim`, `tmux`, `htop`, `nfs-common`, `sudo`, and `bash-completion`.

### 3. Networking Configuration

- Configures static IP addresses for Ethernet and (optionally) Wi-Fi using NetworkManager.
- Applies DNS, gateway, and IP settings from inventory and group variables.

### 4. Docker and NVIDIA GPU Support

- Installs Docker and enables the Docker service at boot.
- Installs the appropriate NVIDIA drivers and firmware for the system’s GPU.
- Installs the NVIDIA Container Toolkit and configures Docker to use the NVIDIA runtime.
- Enables the `nvidia-persistenced` service to manage GPU state between reboots.

### 5. Power Management

- Configures the system to ignore the laptop lid-close event, allowing it to continue running with the lid closed.

### 6. Firewall and Security

- Installs and enables UFW (Uncomplicated Firewall).
- Allows traffic for SSH and Kubernetes control-plane ports through the firewall.

### 7. Kubernetes (k3s) Controller Setup

- Disables swap, as required by Kubernetes.
- Installs `k3s` in server mode with custom options:
  - Sets the node IP address.
  - Disables unused default services.
  - Configures automatic etcd snapshots and retention policy.
- Enables and starts the `k3s` service.
- Installs required networking dependencies for `k3s`.

### 8. NFS and Backup Integration

- Mounts an NFS share for persistent storage.
- Schedules a daily cron job to copy etcd snapshots to the NAS over NFS.

### 9. GPU Support in Kubernetes

- Deploys the NVIDIA Device Plugin DaemonSet for enabling GPU access across the Kubernetes cluster.

### 10. Post-Install Automation

- Sets up a `systemd` service to run `ansible-pull` at boot, ensuring that all playbooks are applied automatically.
- Retrieves the Ansible Vault password securely from a protected endpoint to manage secrets.

### 11. Verification

- Validates that the Kubernetes API server is reachable and operational after setup.

## Setup Instructions

1. **Patch the Debian Installer ISO:**
    - Use the `debian_patcher.sh` script to create a custom Debian installer ISO with the required preseed and isolinux configuration.
    - Example usage:
      ```sh
      ./debian_patcher.sh <path-to-original-debian-iso> <output-iso-name>
      ```
      - `<path-to-original-debian-iso>`: Path to the official Debian ISO you want to patch.
      - `<output-iso-name>`: Name for the new, patched ISO file.
    - The script will:
      - Install required utilities (add `-y` or `--no-confirm` to bypass install confirmation.)
      - Extract the original ISO
      - Copy in the `preseed/` folder and update `isolinux/isolinux.cfg`
      - Rebuild the ISO as specified by the output name

2. **Prepare the Debian Installer Media:**
    - Write the patched ISO to a USB drive or other installation media.

3. **Automated Installation:**
    - Boot the MSI laptop from the prepared Debian installer media.
    - Select "Automated Install" from the boot menu.
    - The installer will use the preseed file for a fully unattended installation, including disk partitioning, user creation, and package installation.

4. **Post-Installation Automation:**
    - At the end of installation, the preseed `late_command` will:
        - Set up a systemd service to run `ansible-pull` at boot.
        - Fetch the Ansible Vault password from your internal vault endpoint.
        - Enable the Ansible pull service for further configuration.

5. **Ongoing Configuration:**
    - After first boot, Ansible will automatically pull and apply the playbooks from this repository (`https://github.com/christag/home-network.git`), configuring the system as a k3s controller and applying any further roles.

## Notes

- Ensure all referenced files are present and paths are correct on your installer media or in the patched ISO.
- The Ansible playbooks and inventory should be maintained in the referenced repository.
- The vault password endpoint (`https://vault.christagliaferro.com/vault-pass`) must be accessible from the target machine during setup.
- You may need to adjust variables and secrets in your Ansible configuration for your environment.
