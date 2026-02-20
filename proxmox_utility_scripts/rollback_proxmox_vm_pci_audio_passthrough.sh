#!/usr/bin/env bash
set -euo pipefail

VMID="${1:-}"
PCI_HOST_ID="${2:-0}"

if [[ -z "$VMID" ]]; then
    echo "Usage: $0 <VMID> [PCI_HOST_ID]"
    exit 1
fi

MODPROBE_FILE="/etc/modprobe.d/vfio.conf"
QEMU_CONF="/etc/pve/qemu-server/${VMID}.conf"
GRUB_FILE="/etc/default/grub"

VM_UPDATED=false
VFIO_UPDATED=false
GRUB_UPDATED=false

HOSTPCI_KEY="hostpci${PCI_HOST_ID}"

echo "Rollback script: VM=$VMID, hostpci slot=$HOSTPCI_KEY"

# 1) Remove hostpci entry from VM config
if [[ -f "$QEMU_CONF" ]]; then
    if grep -q "^${HOSTPCI_KEY}:" "$QEMU_CONF"; then
        sed -i "/^${HOSTPCI_KEY}:/d" "$QEMU_CONF"
        echo "Removed ${HOSTPCI_KEY} from $QEMU_CONF"
        VM_UPDATED=true
        # If VM is running, attempt a graceful reboot to apply changes
        if qm status "$VMID" 2>/dev/null | grep -qi running; then
            echo "Rebooting VM $VMID to apply config changes..."
            qm reboot "$VMID" || true
        fi
    else
        echo "No ${HOSTPCI_KEY} entry found in $QEMU_CONF"
    fi
else
    echo "VM config $QEMU_CONF not found"
fi

# 2) Remove vfio-pci binding from modprobe config
if [[ -f "$MODPROBE_FILE" ]]; then
    # Extract ids value(s) if present
    PCI_IDS=$(grep -Po 'ids=\K[^ ]+' "$MODPROBE_FILE" || true)
    if [[ -n "$PCI_IDS" ]]; then
        # Remove the specific line(s) containing options vfio-pci ids=<PCI_IDS>
        sed -i "\|options vfio-pci ids=${PCI_IDS}|d" "$MODPROBE_FILE" || true
        echo "Removed vfio-pci ids=${PCI_IDS} from $MODPROBE_FILE"
        update-initramfs -u || true
        sleep 2
        VFIO_UPDATED=true
    else
        echo "No vfio-pci ids= entry found in $MODPROBE_FILE"
    fi
else
    echo "$MODPROBE_FILE does not exist"
fi

# 3) Revert GRUB IOMMU kernel flags
if [[ -f "$GRUB_FILE" ]]; then
    sed -i 's/\bintel_iommu=on\b//g' "$GRUB_FILE" || true
    sed -i 's/\bamd_iommu=on\b//g' "$GRUB_FILE" || true
    sed -i 's/\biommu=pt\b//g' "$GRUB_FILE" || true
    # Collapse multiple spaces
    sed -i 's/  */ /g' "$GRUB_FILE" || true
    # Normalize an empty string value
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=" "/GRUB_CMDLINE_LINUX_DEFAULT=""/' "$GRUB_FILE" || true
    echo "Removed IOMMU flags from $GRUB_FILE"
    update-grub || true
    GRUB_UPDATED=true
else
    echo "$GRUB_FILE not found"
fi

if [[ "$VFIO_UPDATED" == true || "$GRUB_UPDATED" == true ]]; then
    echo "Host reboot is required to apply GRUB/vfio changes. Rebooting now..."
    reboot && exit 0
fi

echo "Rollback complete."
exit 0
