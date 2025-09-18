#!/usr/bin/env bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Use sudo." >&2
  exit 1
fi

echo "Disabling VirtualBox modules and enabling KVM + libvirt..."

# Stop VirtualBox services
echo "Stopping VirtualBox services..."
systemctl stop vboxdrv.service vboxautostart-service.service vboxballoonctrl-service.service vboxweb-service.service 2>/dev/null

# Remove VirtualBox kernel modules
echo "Removing VirtualBox kernel modules..."
modprobe -r vboxdrv vboxnetflt vboxnetadp vboxpci 2>/dev/null

# Check and unload conflicting modules
echo "Unloading potentially conflicting modules..."
modprobe -r kvm_intel kvm_amd kvm 2>/dev/null

# Load KVM modules
echo "Loading KVM modules..."
modprobe kvm
if [[ $(lscpu | grep -q "Intel") ]]; then
  modprobe kvm_intel
else
  modprobe kvm_amd
fi

# Enable libvirt services
echo "Enabling and starting libvirt services..."
systemctl enable libvirtd
systemctl start libvirtd

# Verify status
echo "Verifying KVM and libvirt status..."
if lsmod | grep -q kvm; then
  echo "KVM is successfully loaded."
else
  echo "KVM failed to load. Check dmesg for errors." >&2
  exit 1
fi

if systemctl is-active --quiet libvirtd; then
  echo "libvirt is running."
else
  echo "libvirt failed to start. Check systemctl status libvirtd for errors." >&2
  exit 1
fi

echo "VirtualBox disabled and KVM + libvirt enabled successfully."
