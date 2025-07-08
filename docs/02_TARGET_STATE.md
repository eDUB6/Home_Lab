# Target State: Ideal Future Environment

This document describes the ideal, re-architected end-state we are building towards. This is the blueprint for our new, automated, and resilient infrastructure.

## 1. Target Hardware Configuration & Roles

* **Production Server (Cisco UCS M220 M4):**
    * **Role:** Will be wiped and rebuilt as the clean, stable production host.
    * **Storage Config:**
        * **System Pool (Mirror):** 2x 1.6TB U.2 NVMe for Proxmox OS and critical VMs.
        * **Media Pool (Stripe):** 2x 1.6TB U.2 NVMe for high-capacity media storage.

* **Dev/AI Server (HP ML350 Gen9):**
    * **Role:** Will be the primary development, backup, and AI experimentation server.
    * **CPU Config:** Upgraded to 2x Intel Xeon **E5-2650L v3** for power efficiency.
    * **Ideal Storage (Long-Term Goal):**
        * **System Pool (Mirror):** 2x ~2TB High-Endurance U.2 NVMe.
        * **AI/Data Pool (Mirror):** 2x 4-8TB Capacity U.2 NVMe.

## 2. Target Network Architecture

* **Firewall:** Ubiquiti USG Ultra with **Threat Management (IDS/IPS)** enabled.
* **VLANs:** Fully implemented network segmentation:
    * **VLAN 10 (Management):** For infrastructure hardware.
    * **VLAN 20 (Compute):** For trusted servers and workstations.
    * **VLAN 40 (IoT):** For untrusted smart home devices, firewalled from other networks.
    * **VLAN 50 (Guest):** For isolated visitor Wi-Fi.
* **Remote Access:** **WireGuard VPN** hosted on the USG Ultra for secure remote management.

## 3. Target Software Stack & Automation

* **Automation:** All server configurations, from user accounts to application deployment, will be managed by **Ansible** playbooks stored in this Git repository.
* **Backup:** A fully automated 3-2-1 backup strategy will be in place, orchestrated by Ansible, using **Proxmox Backup Server** for local snapshots and **rclone** for future offsite cloud sync.
* **Services:** All applications will be deployed as Docker containers, defined in `docker-compose.yml` files and managed by Ansible. The target stack includes:
    * Plex/Jellyfin
    * AdGuard Home
    * Kanboard
    * SearxNG + OpenWebUI
    * Traefik
    * Vaultwarden
    * Uptime Kuma
