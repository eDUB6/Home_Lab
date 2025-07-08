# AI-Powered Home Lab: Infrastructure & Automation Plan

This repository contains the documentation, scripts, and configurations for building and managing a sophisticated, AI-enhanced home lab. The goal is to create a powerful, resilient, and automated infrastructure using Infrastructure as Code (IaaC) principles.

## Project Documentation

This project is organized into three core documents that outline the vision, architecture, and actionable steps.

* **[Current State (Production)](./docs/01_CURRENT_STATE.md):** Describes the entire homelab environment as it exists today.
* **[Target State (Ideal Future)](./docs/02_TARGET_STATE.md):** Describes the ideal, re-architected end-state we are building towards.
* **[Action Plan & Roadmap](./docs/03_ACTION_PLAN.md):** The detailed, step-by-step guide for migrating from the current state to the target state.

## Vision & Goals

* **Vision:** To create a resilient, self-healing, and AI-assisted home infrastructure that automates routine maintenance, enhances security, and provides a powerful platform for home services and experimentation.
* **Core Principles:**
    * **Infrastructure as Code (IaaC):** All configurations are stored as code in this Git repository.
    * **Automation First:** Repetitive tasks will be automated using Ansible.
    * **Security by Design:** The network will be segmented and hardened from the ground up.
    * **Simplicity & Elegance:** Utilize free, open-source, and performant tools.

## Repository Structure

* `/docs`: Contains all detailed project documentation.
* `/services`: Contains Docker Compose files and configurations for each self-hosted service.
* `/scripts`: Contains standalone scripts, such as the fan controller for the HP server.
