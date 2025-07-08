# Current State: Production Environment

This document describes the current state of the entire homelab infrastructure as of the project's start. This serves as the baseline from which we will migrate.

## 1. Current Hardware Inventory

* **Primary Server (Cisco UCS M220 M4):**
    * **CPUs:** 2x Intel Xeon E5-2699 v4
    * **RAM:** 256GB
    * **Storage:** 4x 1.6TB Samsung U.2 NVMe
    * **Role:** Currently running Proxmox VE and hosting all production VMs, containers, and services.

* **Secondary Server (HP ML350 Gen9):**
    * **CPUs:** 2x Intel Xeon E5-2640 v3 (Original CPUs)
    * **RAM:** 64GB
    * **GPUs:** 2x NVIDIA Tesla P40
    * **Storage:** 1TB WD Blue SN580 NVMe, 1x SATA HDD (for temporary use)
    * **Role:** Currently underutilized, designated to become the new Dev/AI server.

* **Workstations:**
    * **Gaming PC:** AMD 5800X3D, 32GB RAM, 2x 2TB NVMe
    * **Dev Machine:** AMD 3600X, RTX 2070, 32GB RAM

* **Network Infrastructure:**
    * **Firewall/Gateway:** Ubiquiti USG Ultra
    * **Switch:** Zyxel 24-port managed switch
    * **Wireless:** 3x Ubiquiti UAC-AP-Pro Access Points
    * **PDU:** APC7921 Switched Rack PDU

## 2. Current Software & Services

* **Hypervisor:** Proxmox VE running on the Cisco M220.
* **Services:** All current services (Ollama, OpenWebUI, Traefik, etc.) are running within VMs or containers on the M220.
* **Network:** Basic network configuration is in place, but advanced features like full VLAN segmentation and IDS/IPS are not yet implemented.
* **Backup Strategy:** An ad-hoc or manual backup process is currently in place. A formal, automated 3-2-1 strategy has not been implemented.
