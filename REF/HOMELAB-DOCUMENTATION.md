# Home Lab Documentation & Strategy

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Project Vision & Goals](#project-vision--goals)
3. [Hardware Inventory & Recommendations](#hardware-inventory--recommendations)
4. [Architecture Overview](#architecture-overview)
5. [Virtualization & Storage Platform](#virtualization--storage-platform)
6. [AI/ML Infrastructure](#aiml-infrastructure)
7. [Automation, Monitoring & Security](#automation-monitoring--security)
8. [Network & Power Management](#network--power-management)
9. [Core Application Services](#core-application-services)
10. [Home Automation Integration](#home-automation-integration)
11. [Implementation Roadmap](#implementation-roadmap)
12. [Historical Context & Appendix](#historical-context--appendix)
13. [References & Templates](#references--templates)

---

## Executive Summary

This project delivers an enterprise-grade, AI-powered home lab providing:
- High compute and GPU capacity
- Unified automation and monitoring
- Modular, secure, and cost-effective architecture

---

## Project Vision & Goals

- **Primary Goal:** Fully automated, AI-assisted IT administration for the home.
- **Objectives:**  
  - Optimize performance and efficiency
  - Robust, multi-layered backup
  - Secure, segmented networks
  - Private AI-powered search and automation
  - Infrastructure as Code for all configs

---

## Hardware Inventory & Recommendations

### Current Inventory
| Device                  | CPUs                | RAM   | GPUs           | Storage            | Role           |
|-------------------------|---------------------|-------|----------------|--------------------|----------------|
| Cisco UCS M220 M4       | 2x E5-2699 v4       | 256GB | -              | 4x 1.6TB U.2 NVMe  | Production     |
| HP ML350 Gen9           | 2x E5-2640/2650L v3 | 64-128GB | 2x Tesla P40 | 1TB NVMe           | Dev/AI         |
| Gaming PC               | 5800X3D             | 32GB  | -              | 2x 2TB NVMe        | Workstation    |
| Dev Machine             | 3600X               | 32GB  | 1x RTX 2070    | NVMe               | Dev/Test       |

### Recommendations
- **Storage:** Use ZFS mirrors for critical data; expand ML350 storage for AI/data.
- **Power/Cooling:** Add fans for GPUs; ensure UPS and managed PDU.
- **Networking:** Implement VLANs for segmentation.

---

## Architecture Overview

- **Virtualization Layer:** Proxmox VE cluster on UCS & ML350
- **Service Layer:** Dockerized apps (OpenWebUI, SearxNG, Kanboard)
- **Automation Layer:** Ansible, custom scripts, monitoring stack (Prometheus, Grafana)
- **Home Automation:** HomeSeer HS4, MQTT, device integrations

(See `/diagrams/system-architecture.md` for ASCII/visual diagrams.)

---

## Virtualization & Storage Platform

- **Proxmox VE:** Preferred for virtualization (native ZFS, GPU passthrough)
- **Storage:**  
  - UCS M220: OS/critical VMs on mirrored NVMe, media on striped pool
  - ML350: Separate mirrored pools for system and AI/data

- **GlusterFS:** For simple, shared storage between nodes (optionally expand to Ceph if scaling)

---

## AI/ML Infrastructure

- **LLM Backend:** llama.cpp for Tesla P40s, Ollama for dev
- **Model Distribution:** Assign large models to P40s, fast/small ones to RTX 2070
- **Containerization:** Use Docker Compose for easy deployment

See `/configs/docker-compose-llm.yaml` for example deployment.

---

## Automation, Monitoring & Security

- **Automation:** Ansible playbooks for repeatable config (see `/configs/ansible/`)
- **Monitoring:** Prometheus, Grafana, ELK stack
- **Security:**  
  - Zero-trust with VLANs, FreeIPA, 802.1X, Suricata
  - Encrypted backups (3-2-1 strategy)

---

## Network & Power Management

- **Network:**  
  - VLANs: Management (10), Compute (20), AI/ML (30), IoT (40), Guest (50)
  - Jumbo frames for AI VLAN
- **Power:**  
  - UPS (APC 5000VA), managed PDU (APC7921)
  - Scripts for load shedding and monitoring (see `/scripts/ups_monitor.py`, `/scripts/pdu_controller.py`)

---

## Core Application Services

- **Project Management:** Kanboard (API-friendly, lightweight)
- **Private Search:** SearxNG (integrates with OpenWebUI)
- **AI Interface:** OpenWebUI

---

## Home Automation Integration

- **Central Hub:** HomeSeer HS4 (Raspberry Pi)
- **Protocol:** MQTT for device comms
- **Device Integrations:** Harmony Hub, Ecobee, robot vacuums, 3D printer

Automation and integration scripts: `/scripts/`

---

## Implementation Roadmap

See `/docs/ROADMAP-template.md` for a customizable template.

**Example Phases:**
1. Hardware Inventory & Testing
2. Storage Upgrades & Backup Setup
3. Virtualization & Network Segmentation
4. Deploy Core Services
5. Integrate Automation and Monitoring

---

## Historical Context & Appendix

This section preserves major past plans and decisions for reference.

- **2024-2025:**  
  - Original split between “comprehesnsive strategy” and “homelab-complete-docs.md”
  - Early experiments with Ceph, later standardized on GlusterFS for simplicity
  - Shift from ad-hoc scripts to Ansible-centric automation
  - GPU cooling issues resolved with custom fan scripts

- **Major Changes:**  
  - ML350 RAM and CPU upgrades
  - Adoption of SearxNG and OpenWebUI for RAG search
  - Migration to 3-2-1 backup with PBS, Borg, offsite sync

- **Legacy Configs:**  
  - See `/docs/APPENDIX-legacy.md` for old bash configs, unused VM layouts, or deprecated hardware notes.

---

## References & Templates

- [Roadmap Template](docs/ROADMAP-template.md)
- [Inventory Template](docs/INVENTORY-template.md)
- [Example Docker Compose](configs/docker-compose-llm.yaml)
- [Example Ansible Inventory](configs/ansible/inventory.yaml)
- [Monitoring Scripts](scripts/ups_monitor.py, scripts/pdu_controller.py)

---

For further questions, see the README or open an issue.