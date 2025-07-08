# Home_Lab
AI-Powered Home Lab: Infrastructure & Automation Plan
This repository contains the documentation, scripts, and configurations for building and managing a sophisticated, AI-enhanced home lab environment. The goal is to create a powerful, resilient, and automated infrastructure using a combination of enterprise and consumer hardware.
1. Project Vision & Goals
Primary Goal: To create a fully automated, AI-assisted IT administration system for the home lab.
Key Objectives:
Optimize hardware for performance and power efficiency.
Establish a robust, multi-layered backup and recovery strategy.
Implement a secure, segmented network architecture.
Deploy a private, self-hosted search engine integrated with local AI models.
Use Infrastructure as Code (IaaC) principles, with all configurations stored in this Git repository.
2. Hardware & Software Stack
2.1. Recommended Hardware Configuration
Server
Role
CPUs
RAM
GPUs
Storage Configuration
Cisco M220
Production
2x E5-2699 v4
256GB
-
Pool 1 (Mirror): 2x 1.6TB U.2 (System) <br> Pool 2 (Stripe): 2x 1.6TB U.2 (Media)
HP ML350
Dev/AI
2x E5-2650L v3
128GB+
2x Tesla P40
(Future) Pool 1 (Mirror): 2x ~2TB U.2 (System) <br> (Future) Pool 2 (Mirror): 2x 4-8TB U.2 (AI/Data)
Dev PC
Dev/Test
AMD 3600X
32GB
1x RTX 2070
Local NVMe

2.2. Core Software Stack
Component
Tool
Purpose
Hypervisor
Proxmox VE
Main virtualization platform for all servers.
Configuration Mgmt
Ansible
Automating setup, deployment, and configuration tasks.
Containerization
Docker & Docker Compose
Running all applications and services.
Backup
Proxmox Backup Server
Primary backup solution for all VMs and containers.
Project Management
Kanboard
Kanban board for tracking project tasks.
Search Engine
SearxNG
Private metasearch engine for OpenWebUI integration.
AI Interface
OpenWebUI
Web interface for interacting with local AI models.
AI Backend
Ollama & llama.cpp
Running local large language models.

3. Immediate Action Plan
This plan focuses on simple, powerful, and free open-source tools to build a solid foundation.
Step 1: Plan & Procure Future Hardware
Action: Begin searching for the U.2 drives needed for the optimal ML350 configuration as detailed in the storage plan.
System Pool Drives: Look for deals on 2x ~2TB high-endurance U.2 drives (e.g., Intel P4610, Samsung PM983).
AI/Data Pool Drives: Look for deals on 2x 4TB-8TB capacity-focused U.2 drives (e.g., Samsung PM9A3).
Step 2: Backup Current Production System (M220 Server)
Tool: Proxmox Backup Server (PBS).
Action:
Install PBS as a Virtual Machine on the HP ML350 server.
Configure a datastore within PBS using a large drive on the ML350.
From your M220 Proxmox UI, add the new PBS instance as a storage target.
Create and run a backup job for all VMs and containers on the M220. Verify completion.
Step 3: Implement Cooling & Hardware Redistribution
Action (HP ML350):
Prioritize Cooling: Shut down the ML350. Physically install fans to provide direct airflow over the Tesla P40 GPUs.
Perform CPU Swap: While the server is open, swap the existing CPUs with the new E5-2650L v3 CPUs.
Validate: Power on, check BIOS for new CPUs and all RAM, and boot into the OS.
Step 4: Establish the New Development Environment
Action:
Install a fresh instance of Proxmox VE on the ML350's NVMe drive.
Configure basic network settings. This server is now your "Dev/Staging" environment.
Step 5: Document as You Go with Git
Tool: Git.
Action:
Initialize this repository.
As you configure services, save those configuration files into this repository in a structured way (e.g., in a services or configs directory).
4. Potential Risks & Mitigation
Hardware Failure: Mitigated by using redundant ZFS pools (Mirrors) for critical systems and maintaining complete, verified backups with Proxmox Backup Server.
Data Loss: Mitigated by a 3-2-1 backup strategy (local PBS, offsite cloud sync planned for the future) and regular, automated backup jobs.
Configuration Errors: Mitigated by using Ansible for repeatable deployments and storing all configurations in Git, allowing for easy rollbacks to previous versions.
GPU Overheating: Mitigated by physical cooling modifications to the ML350 and the active software-based fan control script.
