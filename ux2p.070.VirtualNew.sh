#!/bin/bash
# 070.VirtualNew.sh
# Author: Gemini
# Date: 2025-10-31
# Purpose: Detects if the system is running on a physical machine, a VM, or in a container.
# This script uses modern and more reliable detection methods than mine (sigh.)

# --- Configuration ---
OUTPUT_FORMAT="KEY_VALUE" # Can be KEY_VALUE or a future format

# --- Initialization ---
VIRT_TYPE="Unknown"
VIRT_DETAIL="-"
FINAL_RESULT=""

# --- Helper Functions ---
print_result() {
    if [ "$OUTPUT_FORMAT" = "KEY_VALUE" ]; then
        echo "Detection_Type: $1"
        echo "Detection_Detail: $2"
    else
        echo "Type: $1, Detail: $2"
    fi
}

# --- 1. Container Detection ---
# Priority: systemd-detect-virt -> cgroup -> specific files

# Method 1.1: systemd-detect-virt (most reliable on systemd)
if command -v systemd-detect-virt &>/dev/null; then
    CONTAINER_TYPE=$(systemd-detect-virt --container)
    if [ $? -eq 0 ]; then
        VIRT_TYPE="Container"
        VIRT_DETAIL="$CONTAINER_TYPE"
    fi
fi

# Method 1.2: Check /proc/1/cgroup (very reliable, works on non-systemd)
if [ "$VIRT_TYPE" = "Unknown" ] && [ -f /proc/1/cgroup ]; then
    if grep -q -E 'docker|kubepods' /proc/1/cgroup; then
        VIRT_TYPE="Container"
        VIRT_DETAIL="docker/k8s"
    elif grep -q -E 'lxc' /proc/1/cgroup; then
        VIRT_TYPE="Container"
        VIRT_DETAIL="lxc"
    fi
fi

# Method 1.3: Check for specific artifacts
if [ "$VIRT_TYPE" = "Unknown" ]; then
    if [ -f /.dockerenv ]; then
        VIRT_TYPE="Container"
        VIRT_DETAIL="docker"
    elif [ -d /proc/vz ] && [ ! -d /proc/bc ]; then
        VIRT_TYPE="Container"
        VIRT_DETAIL="OpenVZ"
    fi
fi


# --- 2. VM Detection (only if not a container) ---
if [ "$VIRT_TYPE" = "Unknown" ]; then
    # Method 2.1: systemd-detect-virt
    if command -v systemd-detect-virt &>/dev/null; then
        VM_TYPE=$(systemd-detect-virt --vm)
        if [ $? -eq 0 ]; then
            VIRT_TYPE="Virtual Machine"
            VIRT_DETAIL="$VM_TYPE"
        fi
    fi

    # Method 2.2: dmidecode (very reliable, but often needs root)
    if [ "$VIRT_TYPE" = "Unknown" ] && command -v dmidecode &>/dev/null && [ "$(id -u)" -eq 0 ]; then
        MANUFACTURER=$(dmidecode -s system-manufacturer)
        PRODUCT=$(dmidecode -s system-product-name)
        case "$MANUFACTURER" in
            "VMware, Inc.") VIRT_DETAIL="VMware" ;;
            "QEMU") VIRT_DETAIL="KVM/QEMU" ;;
            "Microsoft Corporation") VIRT_DETAIL="Hyper-V" ;;
            "innotek GmbH") VIRT_DETAIL="VirtualBox" ;;
            "Xen") VIRT_DETAIL="Xen" ;;
        esac
        if [ "$VIRT_DETAIL" != "-" ]; then VIRT_TYPE="Virtual Machine"; fi
    fi

    # Method 2.3: /sys/class/dmi/id/ (good fallback, no root needed)
    if [ "$VIRT_TYPE" = "Unknown" ] && [ -r /sys/class/dmi/id/sys_vendor ]; then
        SYS_VENDOR=$(cat /sys/class/dmi/id/sys_vendor)
        case "$SYS_VENDOR" in
            "VMware, Inc.") VIRT_DETAIL="VMware" ;;
            "QEMU") VIRT_DETAIL="KVM/QEMU" ;;
            "Microsoft Corporation") VIRT_DETAIL="Hyper-V" ;;
            "innotek GmbH") VIRT_DETAIL="VirtualBox" ;;
            "Xen") VIRT_DETAIL="Xen" ;;
            "Amazon EC2") VIRT_DETAIL="AWS EC2" ;;
        esac
        if [ "$VIRT_DETAIL" != "-" ]; then VIRT_TYPE="Virtual Machine"; fi
    fi

    # Method 2.4: lscpu
    if [ "$VIRT_TYPE" = "Unknown" ] && command -v lscpu &>/dev/null; then
        HYPERVISOR=$(lscpu | grep "Hypervisor vendor" | awk -F': ' '{print $2}')
        if [ -n "$HYPERVISOR" ]; then
            VIRT_TYPE="Virtual Machine"
            VIRT_DETAIL="$HYPERVISOR"
        fi
    fi

    # Method 2.5: /proc/cpuinfo
    if [ "$VIRT_TYPE" = "Unknown" ] && grep -q "hypervisor" /proc/cpuinfo; then
        VIRT_TYPE="Virtual Machine"
        VIRT_DETAIL="Unknown (hypervisor flag found)"
    fi
fi

# --- 3. Final Determination ---
if [ "$VIRT_TYPE" = "Unknown" ]; then
    # Check for specific bare-metal vendor names from DMI
    if [ -r /sys/class/dmi/id/sys_vendor ]; then
        SYS_VENDOR=$(cat /sys/class/dmi/id/sys_vendor)
        case "$SYS_VENDOR" in
            "Dell Inc."|"HP"|"HPE"|"Lenovo"|"Supermicro")
                VIRT_TYPE="Physical"
                VIRT_DETAIL="$SYS_VENDOR"
                ;;
            *)
                VIRT_TYPE="Physical"
                VIRT_DETAIL="Generic Bare Metal"
                ;;
        esac
    else
        VIRT_TYPE="Physical"
        VIRT_DETAIL="-"
    fi
fi

# --- Output ---
echo "<pre><b> Virtualization/Containerization Detection (New)</b>"
print_result "$VIRT_TYPE" "$VIRT_DETAIL"
echo "</pre>"
