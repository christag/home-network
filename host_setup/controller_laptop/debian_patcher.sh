#!/bin/bash
# Run this file to create a customized debian installer .iso using 
#the customized isolinux.cfg and preseed files from this repo.

set -e

if [ $# -lt 1 ] || [ $# -gt 3 ]; then
  echo "Usage: $0 <path-to-debian-installer.iso> [output-iso-name] [--no-confirm|-y]"
  exit 1
fi

ISO_PATH="$1"
OUTPUT_ISO="debian-prepared.iso"
NO_CONFIRM=0

# Parse optional arguments
for arg in "${@:2}"; do
  case $arg in
    --no-confirm|-y)
      NO_CONFIRM=1
      ;;
    *)
      OUTPUT_ISO="$arg"
      ;;
  esac
done

WORK_DIR="debian-iso-extract"
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. Check if mkisofs and 7z are installed, install if not
MISSING_PKGS=()
if ! command -v mkisofs >/dev/null 2>&1; then
  MISSING_PKGS+=(genisoimage)
fi
if ! command -v 7z >/dev/null 2>&1; then
  MISSING_PKGS+=(p7zip-full)
fi

if [ ${#MISSING_PKGS[@]} -ne 0 ]; then
  echo "Missing required packages: ${MISSING_PKGS[*]}"
  if [ "$NO_CONFIRM" -eq 1 ]; then
    echo "Installing missing packages without confirmation..."
    sudo apt-get update
    sudo apt-get install -y "${MISSING_PKGS[@]}"
  else
    read -p "The following packages are required: ${MISSING_PKGS[*]}. Install now? [Y/n]: " yn
    case $yn in
      [Yy]*|"")
        sudo apt-get update
        sudo apt-get install -y "${MISSING_PKGS[@]}"
        ;;
      *)
        echo "Aborting. Required packages are missing."
        exit 1
        ;;
    esac
  fi
fi

# 2. Unzip the files from the debian iso to a folder
rm -rf "$WORK_DIR"
mkdir "$WORK_DIR"
7z x "$ISO_PATH" -o"$WORK_DIR"

# 3. Replace isolinux/isolinux.cfg
cp "$THIS_DIR/isolinux/isolinux.cfg" "$WORK_DIR/isolinux/isolinux.cfg"

# 4. Replace grub/boot/grub.cfg
cp "$THIS_DIR/grub/boot/grub.cfg" "$WORK_DIR/grub/boot/grub.cfg"

# 5. Copy preseed folder
cp -r "$THIS_DIR/preseed" "$WORK_DIR/"

# 6. Rebuild ISO
mkisofs -o "$OUTPUT_ISO" \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -J -R -V "Patched Debian Installer" "$WORK_DIR"

echo "Done. Output: $OUTPUT_ISO"