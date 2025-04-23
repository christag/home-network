# Controller Laptop Host Setup (MSI)

This folder contains resources to fully automate the installation and configuration of the MSI controller laptop as a k3s controller node using Debian, preseed, and Ansible.

## Folder Structure

- **debian_patcher.sh**  
  Script to automate patching a stock Debian ISO with the preseed and isolinux configuration for unattended installation.
- **preseed/controller.preseed**  
  Automated Debian installation configuration. Sets up disk, user, packages, and runs post-install automation directly via preseed's `late_command`.
- **isolinux/isolinux.cfg**  
  Bootloader configuration for the Debian installer. Adds a menu entry for automated install using the provided preseed file.

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
