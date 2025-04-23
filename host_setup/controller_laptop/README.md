# Controller Laptop Host Setup (MSI)

This folder contains resources to fully automate the installation and configuration of the MSI controller laptop as a k3s controller node using Debian, preseed, and Ansible.

## Folder Structure

- **preseed/controller.preseed**  
  Automated Debian installation configuration. Sets up disk, user, packages, and runs post-install automation directly via preseed's `late_command`.

- **isolinux/isolinux.cfg**  
  Bootloader configuration for the Debian installer. Adds a menu entry for automated install using the provided preseed file.

## Setup Instructions

1. **Prepare the Debian Installer Media:**
    - Copy the contents of the `isolinux/isolinux.cfg` file to your installer media's `isolinux.cfg`.
    - Copy the entire `preseed/` folder to the root of your installer media.

2. **Automated Installation:**
    - Boot the MSI laptop from the prepared Debian installer media.
    - Select "Automated Install" from the boot menu.
    - The installer will use the preseed file for a fully unattended installation, including disk partitioning, user creation, and package installation.

3. **Post-Installation Automation:**
    - At the end of installation, the preseed `late_command` will:
        - Set up a systemd service to run `ansible-pull` at boot.
        - Fetch the Ansible Vault password from your internal vault endpoint.
        - Enable the Ansible pull service for further configuration.

4. **Ongoing Configuration:**
    - After first boot, Ansible will automatically pull and apply the playbooks from this repository (`https://github.com/christag/home-network.git`), configuring the system as a k3s controller and applying any further roles.

## Notes

- Ensure all referenced files are present and paths are correct on your installer media.
- The Ansible playbooks and inventory should be maintained in the referenced repository.
- The vault password endpoint (`https://vault.christagliaferro.com/vault-pass`) must be accessible from the target machine during setup.
- You may need to adjust variables and secrets in your Ansible configuration for your environment.
