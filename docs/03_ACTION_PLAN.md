# Project Action Plan & Roadmap

This document outlines the actionable, step-by-step plan for migrating the homelab from its current state to the target architecture.

## Phase 1: Preparation & Backup (Current Focus)

* **Task 1.1: Plan & Procure Future Hardware**
    * **Status:** In Progress
    * **Action:** Begin shopping for the U.2 drives for the ML350 as outlined in the [Target State Doc](./02_TARGET_STATE.md). This is a background task.

* **Task 1.2: Backup the Current M220 Environment**
    * **Status:** To Do
    * **Goal:** Create a complete, verified backup of the current production server before making any changes.
    * **Steps:**
        1.  On the **ML350**, install a fresh Proxmox VE instance on its 1TB NVMe drive.
        2.  Inside this new Proxmox, create a VM and install **Proxmox Backup Server (PBS)**.
        3.  Pass the large SATA HDD through to the PBS VM and configure it as a backup datastore.
        4.  From the **M220's** web UI, add the new PBS instance as a storage target.
        5.  Create and run a backup job for **ALL** VMs and containers currently on the M220.
        6.  **VERIFY THE BACKUP** by performing a test restore of a small, non-critical VM onto the ML350.

## Phase 2: Hardware Redistribution & Dev Environment Setup

* **Task 2.1: Reconfigure the ML350 Server**
    * **Status:** To Do
    * **Prerequisite:** Task 1.2 must be complete and verified.
    * **Steps:**
        1.  Shut down the ML350.
        2.  Install the physical cooling for the Tesla P40s.
        3.  Swap the CPUs to the new **E5-2650L v3** processors.
        4.  Power on and validate that the hardware is recognized correctly in the BIOS.

* **Task 2.2: Establish Ansible Control Node**
    * **Status:** To Do
    * **Prerequisite:** Task 2.1 must be complete.
    * **Steps:**
        1.  On the newly configured ML350 Proxmox host, create a lightweight Debian or Ubuntu Server VM.
        2.  Install `ansible` and `git` on this VM.
        3.  Clone this repository (`Home_Lab`) to the new Ansible Control Node.

## Phase 3: Production Redeployment

* **Task 3.1: Rebuild the M220 Server**
    * **Status:** To Do
    * **Prerequisite:** All Phase 2 tasks must be complete.
    * **Steps:**
        1.  Wipe the M220.
        2.  Configure the 4 x 1.6TB U.2 drives into the planned ZFS pools (Mirror + Stripe).
        3.  Install a fresh instance of Proxmox VE on the mirrored system pool.

* **Task 3.2: Automated Restore & Deployment**
    * **Status:** To Do
    * **Prerequisite:** Task 3.1 must be complete.
    * **Steps:**
        1.  From the Ansible Control Node, run playbooks that connect to the new M220.
        2.  These playbooks will automatically configure Proxmox and trigger a full restore of all VMs and containers from the Proxmox Backup Server.
