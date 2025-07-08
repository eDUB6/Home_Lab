# Home Lab Infrastructure: Complete Documentation

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Hardware Inventory](#hardware-inventory)
3. [Architecture Overview](#architecture-overview)
4. [Virtualization Platform](#virtualization-platform)
5. [AI/ML Infrastructure](#aiml-infrastructure)
6. [Home Automation Integration](#home-automation-integration)
7. [Network Architecture](#network-architecture)
8. [Power Management](#power-management)
9. [Implementation Roadmap](#implementation-roadmap)
10. [Operations Guide](#operations-guide)

---

## Executive Summary

This document provides comprehensive documentation for an enterprise-grade home lab featuring:

- **88-thread compute capacity** with Cisco UCS blade servers
- **48GB VRAM** for AI/ML workloads via dual Tesla P40 GPUs
- **Unified automation platform** integrating enterprise and consumer technologies
- **Zero-trust security architecture** with comprehensive monitoring
- **Estimated ROI**: 6-12 months based on cloud compute savings

### Key Design Principles

1. **Enterprise reliability** with consumer flexibility
2. **AI-first automation** for intelligent home management
3. **Energy efficiency** through predictive optimization
4. **Modular architecture** for incremental deployment
5. **Cost-effectiveness** compared to cloud alternatives

---

## Hardware Inventory

### Primary Infrastructure

#### Cisco UCS M220 M4 Blade Server
- **CPU**: Dual Intel Xeon E5-2699 v4 (22-core, 2.2GHz)
- **Cores/Threads**: 44 physical cores, 88 threads
- **RAM**: 256GB DDR4 ECC
- **Storage**: 4x Samsung KPM6XVUG1T60 (1TB U.2 NVMe each)
- **Network**: Integrated 10GbE fabric interconnect
- **Management**: Cisco IMC (CIMC)
- **Power**: 290W TDP per CPU, ~600W typical load

#### HP ML350 Gen9 Tower Server
- **CPU**: 2x Intel Xeon E5-2640 v3 (8-core, 2.6GHz)
- **RAM**: 64GB DDR4 ECC (expandable to 128GB)
- **GPU**: 2x NVIDIA Tesla P40 (24GB VRAM each)
- **Storage**: WD Blue SN580 1TB NVMe
- **Network**: 4x 1GbE, upgradeable to 10GbE
- **Management**: HP iLO 4
- **Power**: ~1000W with dual GPUs

#### Gaming/Workstation PC
- **CPU**: AMD Ryzen 7 5800X3D
- **RAM**: 32GB DDR4
- **Storage**: 2x 2TB NVMe drives
- **Network**: 2.5GbE onboard
- **Power**: ~400W typical gaming load

#### Development Machine
- **CPU**: AMD Ryzen 5 3600X
- **GPU**: NVIDIA RTX 2070 (8GB VRAM)
- **RAM**: 32GB DDR4
- **Use Case**: Available for reallocation or dedicated development

### Spare Components
- **CPUs**: 2x Intel E5-2650L v3 (12-core, 1.8GHz, 65W TDP)
- **GPU**: RTX 2070 (from dev machine if reallocated)
- **Storage**: Various SSDs and HDDs

### Infrastructure Components
- **PDU**: APC7921 8-outlet managed PDU with power monitoring
- **UPS**: Requirement for 5000VA/4000W unit
- **Cooling**: Mini-split AC system recommended (12-24K BTU)
- **Network**: 10GbE switching infrastructure required

### Home Automation Devices
- **Hub**: Raspberry Pi running HomeSeer HS4
- **Entertainment**: Harmony Hub for AV control
- **HVAC**: Ecobee thermostats with API access
- **Cleaning**: 2x robot vacuums (mixed brands)
- **Manufacturing**: 3D printer with OctoPrint
- **Compute**: Various thin clients for distributed tasks

---

## Architecture Overview

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     Management & Orchestration Layer              │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │ Ansible     │  │ Prometheus/  │  │ AI Orchestrator        │ │
│  │ Automation  │  │ Grafana      │  │ (MCP Server)           │ │
│  └─────────────┘  └──────────────┘  └────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────────┐
│                        Virtualization Layer                       │
│  ┌─────────────────────────┐  ┌──────────────────────────────┐ │
│  │ Proxmox VE Cluster      │  │ GlusterFS Shared Storage     │ │
│  │ - Node 1: UCS M220      │  │ - Replicated volumes         │ │
│  │ - Node 2: HP ML350      │  │ - ZFS backend                │ │
│  └─────────────────────────┘  └──────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────────┐
│                         Service Layer                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────────┐ │
│  │ AI/ML    │  │ Home     │  │ Dev/Test │  │ Infrastructure │ │
│  │ Services │  │ Automation│  │ Environ. │  │ Services       │ │
│  └──────────┘  └──────────┘  └──────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────────┐
│                      Physical Infrastructure                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌───────────┐ │
│  │ Cisco UCS  │  │ HP ML350   │  │ Gaming PC  │  │ Network   │ │
│  │ M220 M4    │  │ + 2xP40    │  │ 5800X3D    │  │ 10GbE     │ │
│  └────────────┘  └────────────┘  └────────────┘  └───────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

1. **Hypervisor**: Proxmox VE over ESXi
   - Open-source, no licensing costs
   - Excellent hardware compatibility
   - Native ZFS and Ceph support
   - Strong GPU passthrough capabilities

2. **Storage**: GlusterFS over Ceph
   - Simpler for 2-node setup
   - ZFS backend for data integrity
   - Good performance for VM workloads

3. **AI/ML Framework**: llama.cpp
   - Optimized for Pascal architecture
   - Efficient quantization support
   - Better performance than alternatives on P40

4. **Automation**: HomeSeer HS4 + MQTT
   - Extensive device support
   - Reliable automation engine
   - Good API for integration

---

## Virtualization Platform

### Proxmox VE Configuration

#### Installation Guidelines

**CRITICAL**: Install Proxmox on NVMe drives, NOT SD cards
- SD cards show ~600 day lifespan under continuous writes
- Use enterprise NVMe for OS (120-256GB sufficient)
- Configure separate data pools for VMs

#### Cluster Configuration

```bash
# Node 1 (UCS M220)
pvecm create homelab-cluster

# Node 2 (HP ML350)
pvecm add 10.20.0.10 --link0 10.20.0.20
```

#### Storage Configuration

```bash
# GlusterFS setup
gluster peer probe ml350.local
gluster volume create vm-storage replica 2 \
  ucs:/data/gluster ml350:/data/gluster
gluster volume start vm-storage

# Mount in Proxmox
mkdir -p /mnt/pve/gluster
mount -t glusterfs localhost:/vm-storage /mnt/pve/gluster
```

#### GPU Passthrough Configuration

```bash
# /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction video=efifb:off"

# /etc/modprobe.d/blacklist.conf
blacklist nouveau
blacklist nvidia

# /etc/modprobe.d/vfio.conf
options vfio-pci ids=10de:1b38  # Tesla P40 device ID
```

### VM Architecture

#### Recommended VM Distribution

**UCS M220 M4 (High-Performance)**:
- Database servers
- Application servers
- Development environments
- CI/CD infrastructure

**HP ML350 Gen9 (GPU Workloads)**:
- AI/ML inference servers
- GPU-accelerated applications
- Media processing
- Development testing

---

## AI/ML Infrastructure

### Tesla P40 Optimization

#### Hardware Configuration

1. **BIOS Settings** (HP ML350):
   - Enable "Above 4G Decoding"
   - Disable CSM
   - Set PCIe slots to Gen3 x16
   - Enable SR-IOV if available

2. **Cooling Modifications**:
   - Tesla P40s are passively cooled
   - Add 120mm fans directly to heatsink
   - Monitor temperatures (target <80°C)

#### Software Stack

##### Primary Framework: llama.cpp

```bash
# Installation
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
make LLAMA_CUBLAS=1

# Model quantization
./quantize models/llama-2-13b/ggml-model-f16.bin \
  models/llama-2-13b/ggml-model-q4_K_M.bin q4_K_M
```

##### Model Deployment

```yaml
# docker-compose.yml for LLM inference
version: '3.8'
services:
  llama-server:
    image: ghcr.io/ggerganov/llama.cpp:server-cuda
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    volumes:
      - ./models:/models
    command: 
      - "-m"
      - "/models/llama-2-13b-chat.Q4_K_M.gguf"
      - "-ngl"
      - "43"  # Layers on GPU
      - "-c"
      - "4096"  # Context size
      - "--host"
      - "0.0.0.0"
    ports:
      - "8080:8080"
```

### Model Recommendations

#### For 24GB VRAM (Single P40)

| Model | Quantization | VRAM Usage | Performance |
|-------|--------------|------------|-------------|
| Llama 2 70B | Q2_K | ~23GB | 3-5 tokens/sec |
| Llama 2 13B | Q4_K_M | ~7.5GB | 10-15 tokens/sec |
| Code Llama 34B | Q3_K_M | ~15GB | 5-8 tokens/sec |
| Mixtral 8x7B | Q3_K_M | ~19GB | 4-6 tokens/sec |

#### Multi-GPU Configuration (2x P40)

```python
# Distributed inference setup
class DistributedLLM:
    def __init__(self):
        self.models = {
            'fast': {
                'model': 'llama-2-13b-chat.Q4_K_M.gguf',
                'gpu': 0,
                'layers': 43
            },
            'large': {
                'model': 'llama-2-70b-chat.Q3_K_M.gguf',
                'gpu': 1,
                'layers': 83
            }
        }
    
    def route_request(self, prompt, max_tokens):
        if max_tokens < 1000:
            return self.models['fast']
        else:
            return self.models['large']
```

### AI Workload Orchestration

```yaml
# kubernetes/deployments/ai-inference.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: llm-inference
spec:
  replicas: 2
  selector:
    matchLabels:
      app: llm-inference
  template:
    metadata:
      labels:
        app: llm-inference
    spec:
      containers:
      - name: llama-cpp
        image: llama-cpp:latest
        resources:
          limits:
            nvidia.com/gpu: 1
        env:
        - name: MODEL_PATH
          value: "/models/llama-2-13b-chat.gguf"
        - name: GPU_LAYERS
          value: "43"
```

---

## Home Automation Integration

### Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                   User Interfaces                         │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────┐    │
│  │ Web UI   │  │ Mobile   │  │ Voice Assistant    │    │
│  │          │  │ App      │  │ (Local)            │    │
│  └──────────┘  └──────────┘  └────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│              Automation & Control Layer                   │
│  ┌────────────────────────────────────────────────┐    │
│  │ HomeSeer HS4 (Primary Controller)              │    │
│  │ - Event Engine                                 │    │
│  │ - Device Management                            │    │
│  │ - Plugin System                                │    │
│  └────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                 Communication Layer                       │
│  ┌──────────┐  ┌──────────┐  ┌────────────────────┐    │
│  │ MQTT     │  │ REST API │  │ WebSocket          │    │
│  │ Broker   │  │ Gateway  │  │ Server             │    │
│  └──────────┘  └──────────┘  └────────────────────┘    │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                    Device Layer                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │ Harmony  │  │ Ecobee   │  │ Vacuums  │  │ 3D     │ │
│  │ Hub      │  │ Thermos  │  │          │  │ Printer│ │
│  └──────────┘  └──────────┘  └──────────┘  └────────┘ │
└─────────────────────────────────────────────────────────┘
```

### HomeSeer HS4 Configuration

```javascript
// config/homeseer/mqtt-bridge.js
const mqtt = require('mqtt');
const axios = require('axios');

class HomeSeerMQTTBridge {
    constructor(hsUrl, hsUsername, hsPassword) {
        this.hsUrl = hsUrl;
        this.auth = Buffer.from(`${hsUsername}:${hsPassword}`).toString('base64');
        this.client = mqtt.connect('mqtt://localhost:1883');
        
        this.setupSubscriptions();
    }
    
    setupSubscriptions() {
        this.client.subscribe('home/+/+/set');
        this.client.subscribe('home/+/+/get');
        
        this.client.on('message', (topic, message) => {
            const parts = topic.split('/');
            const device = parts[1];
            const property = parts[2];
            const action = parts[3];
            
            if (action === 'set') {
                this.setDeviceValue(device, property, message.toString());
            }
        });
    }
    
    async setDeviceValue(device, property, value) {
        const response = await axios.get(`${this.hsUrl}/JSON`, {
            params: {
                request: 'controldevicebyvalue',
                ref: device,
                value: value
            },
            headers: {
                'Authorization': `Basic ${this.auth}`
            }
        });
        
        // Publish confirmation
        this.client.publish(`home/${device}/${property}/state`, value);
    }
}
```

### Device Integration Examples

#### Harmony Hub Control

```python
# scripts/harmony_integration.py
import asyncio
import aioharmony

class HarmonyController:
    def __init__(self, hub_ip):
        self.hub_ip = hub_ip
        self.client = None
    
    async def connect(self):
        self.client = await aioharmony.HarmonyAPI(self.hub_ip).connect()
    
    async def start_activity(self, activity_name):
        activities = await self.client.get_activities()
        activity_id = next(
            (a['id'] for a in activities if a['label'] == activity_name),
            None
        )
        if activity_id:
            await self.client.start_activity(activity_id)
    
    async def send_command(self, device, command):
        await self.client.send_command(device, command)
```

#### Ecobee Integration

```python
# scripts/ecobee_integration.py
import requests
from datetime import datetime, timedelta

class EcobeeController:
    def __init__(self, api_key, refresh_token):
        self.api_key = api_key
        self.refresh_token = refresh_token
        self.access_token = None
        self.token_expiry = None
    
    def refresh_access_token(self):
        response = requests.post(
            'https://api.ecobee.com/token',
            params={
                'grant_type': 'refresh_token',
                'refresh_token': self.refresh_token,
                'client_id': self.api_key
            }
        )
        data = response.json()
        self.access_token = data['access_token']
        self.token_expiry = datetime.now() + timedelta(seconds=data['expires_in'])
    
    def set_temperature(self, thermostat_id, heat_temp, cool_temp):
        if not self.access_token or datetime.now() >= self.token_expiry:
            self.refresh_access_token()
        
        response = requests.post(
            'https://api.ecobee.com/1/thermostat',
            headers={'Authorization': f'Bearer {self.access_token}'},
            json={
                'selection': {'selectionType': 'thermostats', 'selectionMatch': thermostat_id},
                'thermostat': {
                    'runtime': {
                        'desiredHeat': heat_temp * 10,  # Ecobee uses tenths of degrees
                        'desiredCool': cool_temp * 10
                    }
                }
            }
        )
        return response.json()
```

### AI-Driven Automation

#### Occupancy Detection System

```python
# scripts/ai_occupancy_detection.py
import numpy as np
from sklearn.ensemble import RandomForestClassifier
import joblib

class OccupancyDetector:
    def __init__(self, model_path='models/occupancy_model.pkl'):
        self.model = joblib.load(model_path)
        self.feature_names = ['co2', 'temperature', 'humidity', 'light', 'sound']
    
    def predict_occupancy(self, sensor_data):
        """
        Predict room occupancy based on sensor data
        
        Args:
            sensor_data: dict with keys matching feature_names
        
        Returns:
            probability of occupancy (0-1)
        """
        features = np.array([[
            sensor_data.get(f, 0) for f in self.feature_names
        ]])
        
        probability = self.model.predict_proba(features)[0, 1]
        return probability
    
    def get_occupancy_pattern(self, historical_data):
        """
        Analyze historical patterns for predictive scheduling
        """
        # Group by hour of day and day of week
        patterns = {}
        for record in historical_data:
            hour = record['timestamp'].hour
            day = record['timestamp'].weekday()
            key = f"{day}_{hour}"
            
            if key not in patterns:
                patterns[key] = []
            
            patterns[key].append(record['occupied'])
        
        # Calculate average occupancy probability
        occupancy_schedule = {}
        for key, values in patterns.items():
            occupancy_schedule[key] = np.mean(values)
        
        return occupancy_schedule
```

#### Energy Optimization Engine

```python
# scripts/energy_optimizer.py
import numpy as np
from datetime import datetime, timedelta

class EnergyOptimizer:
    def __init__(self, occupancy_predictor, weather_api):
        self.occupancy_predictor = occupancy_predictor
        self.weather_api = weather_api
        self.comfort_temp_range = (68, 78)  # Fahrenheit
        self.setback_temp_range = (60, 85)
    
    def calculate_optimal_schedule(self, current_date):
        """
        Calculate optimal HVAC schedule for the next 24 hours
        """
        schedule = []
        
        for hour in range(24):
            timestamp = current_date + timedelta(hours=hour)
            
            # Get occupancy probability
            occupancy_prob = self.occupancy_predictor.predict_for_time(timestamp)
            
            # Get weather forecast
            outdoor_temp = self.weather_api.get_forecast(timestamp)['temperature']
            
            # Calculate optimal setpoint
            if occupancy_prob > 0.7:
                # Occupied - maintain comfort
                heat_setpoint = self.comfort_temp_range[0]
                cool_setpoint = self.comfort_temp_range[1]
            elif occupancy_prob > 0.3:
                # Possibly occupied - mild setback
                heat_setpoint = self.comfort_temp_range[0] - 3
                cool_setpoint = self.comfort_temp_range[1] + 3
            else:
                # Unoccupied - maximum setback
                heat_setpoint = self.setback_temp_range[0]
                cool_setpoint = self.setback_temp_range[1]
            
            # Pre-conditioning logic
            if hour < 23:  # Not the last hour
                next_occupancy = self.occupancy_predictor.predict_for_time(
                    timestamp + timedelta(hours=1)
                )
                if next_occupancy > 0.7 and occupancy_prob < 0.3:
                    # Pre-heat/cool for upcoming occupancy
                    heat_setpoint = self.comfort_temp_range[0] - 1
                    cool_setpoint = self.comfort_temp_range[1] + 1
            
            schedule.append({
                'time': timestamp,
                'heat_setpoint': heat_setpoint,
                'cool_setpoint': cool_setpoint,
                'occupancy_probability': occupancy_prob
            })
        
        return schedule
```

---

## Network Architecture

### VLAN Design

```
┌─────────────────────────────────────────────────────────────┐
│                    Network Topology                           │
│                                                               │
│  Internet ────► Firewall ────► Core Switch (10GbE)          │
│                                      │                        │
│                    ┌─────────────────┼─────────────────┐    │
│                    │                 │                 │      │
│              VLAN 10           VLAN 20           VLAN 30     │
│            Management        Enterprise          AI/ML        │
│           10.10.0.0/24      10.20.0.0/24     10.30.0.0/24   │
│                    │                 │                 │      │
│                    │                 │                 │      │
│              VLAN 40           VLAN 50           VLAN 99     │
│                IoT              Guest           Isolated      │
│           10.40.0.0/24      10.50.0.0/24     10.99.0.0/24   │
└─────────────────────────────────────────────────────────────┘
```

### VLAN Configuration

```bash
# /etc/network/interfaces (Proxmox nodes)
auto vmbr0
iface vmbr0 inet manual
    bridge_ports eno1
    bridge_stp off
    bridge_fd 0
    bridge_vlan_aware yes

# Management VLAN
auto vmbr0.10
iface vmbr0.10 inet static
    address 10.10.0.10/24
    gateway 10.10.0.1

# Enterprise VLAN
auto vmbr0.20
iface vmbr0.20 inet static
    address 10.20.0.10/24

# AI/ML VLAN (high-speed)
auto vmbr0.30
iface vmbr0.30 inet static
    address 10.30.0.10/24
    mtu 9000  # Jumbo frames for AI workloads
```

### Firewall Rules

```bash
# Basic inter-VLAN routing rules
# Management can access everything
iptables -A FORWARD -s 10.10.0.0/24 -j ACCEPT

# Enterprise can access AI/ML
iptables -A FORWARD -s 10.20.0.0/24 -d 10.30.0.0/24 -j ACCEPT

# IoT isolated from other VLANs except specific services
iptables -A FORWARD -s 10.40.0.0/24 -d 10.20.0.100 -p tcp --dport 1883 -j ACCEPT  # MQTT
iptables -A FORWARD -s 10.40.0.0/24 -j DROP

# Guest network isolation
iptables -A FORWARD -s 10.50.0.0/24 -d 10.0.0.0/8 -j DROP
iptables -A FORWARD -s 10.50.0.0/24 -j ACCEPT  # Internet only
```

### High-Performance Networking

#### 10GbE Configuration

```bash
# Enable jumbo frames on 10GbE interfaces
ip link set dev ens1f0 mtu 9000

# CPU affinity for network interrupts
# Find interrupt numbers
grep ens1f0 /proc/interrupts

# Set CPU affinity (example for interrupt 24)
echo 2 > /proc/irq/24/smp_affinity  # Pin to CPU 1
```

#### InfiniBand Setup (Alternative)

```bash
# Load IB modules
modprobe ib_core
modprobe mlx4_ib
modprobe ib_ipoib

# Configure IPoIB
echo connected > /sys/class/net/ib0/mode
ip link set dev ib0 mtu 65520
ip addr add 192.168.100.10/24 dev ib0
ip link set dev ib0 up
```

---

## Power Management

### Power Requirements Analysis

#### Component Power Draw

| Component | Idle | Typical | Maximum |
|-----------|------|---------|---------|
| Cisco UCS M220 | 200W | 400W | 600W |
| HP ML350 + 2xP40 | 300W | 700W | 1000W |
| Gaming PC | 100W | 250W | 400W |
| Network Equipment | 100W | 150W | 200W |
| Home Automation | 50W | 75W | 100W |
| **Total** | **750W** | **1575W** | **2300W** |

### UPS Configuration

#### Recommended: APC Smart-UPS 5000VA

```python
# scripts/ups_monitor.py
import pysnmp
from pysnmp.hlapi import *

class UPSMonitor:
    def __init__(self, ups_ip, community='public'):
        self.ups_ip = ups_ip
        self.community = community
        self.oids = {
            'battery_capacity': '1.3.6.1.4.1.318.1.1.1.2.2.1.0',
            'battery_runtime': '1.3.6.1.4.1.318.1.1.1.2.2.3.0',
            'input_voltage': '1.3.6.1.4.1.318.1.1.1.3.2.1.0',
            'output_load': '1.3.6.1.4.1.318.1.1.1.4.2.3.0'
        }
    
    def get_status(self):
        status = {}
        
        for name, oid in self.oids.items():
            iterator = getCmd(
                SnmpEngine(),
                CommunityData(self.community),
                UdpTransportTarget((self.ups_ip, 161)),
                ContextData(),
                ObjectType(ObjectIdentity(oid))
            )
            
            for response in iterator:
                error_indication, error_status, error_index, var_binds = response
                
                if not error_indication and not error_status:
                    for var_bind in var_binds:
                        status[name] = var_bind[1]
        
        return status
    
    def calculate_runtime(self, current_load_watts):
        """Calculate estimated runtime based on current load"""
        battery_capacity = self.get_status()['battery_capacity']
        
        # Rough estimation (adjust based on your UPS specs)
        full_load_runtime = 15  # minutes at 4000W
        current_runtime = full_load_runtime * (4000 / current_load_watts)
        adjusted_runtime = current_runtime * (battery_capacity / 100)
        
        return adjusted_runtime
```

### APC7921 PDU Integration

```python
# scripts/pdu_controller.py
import requests
from dataclasses import dataclass
from typing import Dict, List

@dataclass
class PDUOutlet:
    number: int
    name: str
    status: str  # 'on', 'off', 'reboot'
    current_draw: float  # Amps

class APC7921Controller:
    def __init__(self, pdu_ip, username='apc', password='apc'):
        self.pdu_ip = pdu_ip
        self.auth = (username, password)
        self.outlets = {
            1: "Cisco UCS M220",
            2: "HP ML350 Gen8",
            3: "Gaming PC",
            4: "Dev Machine",
            5: "Network Core",
            6: "Network Edge",
            7: "Home Automation",
            8: "Auxiliary"
        }
    
    def get_outlet_status(self, outlet_number: int) -> PDUOutlet:
        """Get status of specific outlet"""
        # This would typically use SNMP or the web API
        # Simplified example
        url = f"http://{self.pdu_ip}/outlet/{outlet_number}"
        response = requests.get(url, auth=self.auth)
        data = response.json()
        
        return PDUOutlet(
            number=outlet_number,
            name=self.outlets[outlet_number],
            status=data['status'],
            current_draw=data['current']
        )
    
    def control_outlet(self, outlet_number: int, action: str):
        """Control outlet (on/off/reboot)"""
        url = f"http://{self.pdu_ip}/outlet/{outlet_number}/control"
        response = requests.post(
            url,
            auth=self.auth,
            json={'action': action}
        )
        return response.json()
    
    def get_total_power(self) -> float:
        """Calculate total power consumption"""
        total_amps = 0
        for outlet_num in range(1, 9):
            outlet = self.get_outlet_status(outlet_num)
            if outlet.status == 'on':
                total_amps += outlet.current_draw
        
        # Assuming 120V (adjust for your region)
        return total_amps * 120
    
    def implement_load_shedding(self, target_reduction_watts: float):
        """Implement emergency load shedding"""
        priority_order = [8, 7, 4, 3]  # Least critical first
        
        current_reduction = 0
        for outlet in priority_order:
            if current_reduction >= target_reduction_watts:
                break
            
            status = self.get_outlet_status(outlet)
            if status.status == 'on':
                outlet_power = status.current_draw * 120
                self.control_outlet(outlet, 'off')
                current_reduction += outlet_power
                print(f"Shed load: {status.name} ({outlet_power}W)")
```

### Intelligent Power Management

```python
# scripts/power_optimizer.py
from datetime import datetime, time
import numpy as np

class PowerOptimizer:
    def __init__(self, pdu_controller, ups_monitor):
        self.pdu = pdu_controller
        self.ups = ups_monitor
        self.peak_hours = (time(14, 0), time(19, 0))  # 2 PM - 7 PM
        self.off_peak_hours = (time(22, 0), time(6, 0))  # 10 PM - 6 AM
    
    def is_peak_time(self) -> bool:
        """Check if current time is during peak hours"""
        now = datetime.now().time()
        return self.peak_hours[0] <= now <= self.peak_hours[1]
    
    def is_off_peak_time(self) -> bool:
        """Check if current time is during off-peak hours"""
        now = datetime.now().time()
        if self.off_peak_hours[0] <= self.off_peak_hours[1]:
            return self.off_peak_hours[0] <= now <= self.off_peak_hours[1]
        else:
            return now >= self.off_peak_hours[0] or now <= self.off_peak_hours[1]
    
    def schedule_workloads(self):
        """Schedule power-intensive workloads"""
        schedules = []
        
        if self.is_peak_time():
            # Minimize power during peak
            schedules.append({
                'action': 'reduce_gpu_power',
                'target': 'ml350',
                'power_limit': 150  # Watts per GPU
            })
            schedules.append({
                'action': 'pause_batch_jobs',
                'target': 'ucs'
            })
        
        elif self.is_off_peak_time():
            # Run intensive workloads during off-peak
            schedules.append({
                'action': 'start_ml_training',
                'target': 'ml350'
            })
            schedules.append({
                'action': 'run_backups',
                'target': 'all'
            })
        
        return schedules
    
    def monitor_and_adjust(self):
        """Continuous monitoring and adjustment"""
        ups_status = self.ups.get_status()
        total_power = self.pdu.get_total_power()
        
        # Check if on battery power
        if ups_status['input_voltage'] < 100:  # On battery
            runtime = self.ups.calculate_runtime(total_power)
            
            if runtime < 30:  # Less than 30 minutes
                # Aggressive power saving
                self.implement_graceful_shutdown()
            elif runtime < 60:  # Less than 1 hour
                # Moderate power saving
                self.pdu.implement_load_shedding(500)  # Shed 500W
        
        # Check if approaching circuit limit
        if total_power > 1800:  # 80% of 20A circuit
            self.pdu.implement_load_shedding(total_power - 1600)
    
    def implement_graceful_shutdown(self):
        """Gracefully shutdown non-critical systems"""
        shutdown_order = [
            ('dev_machine', 60),    # 1 minute warning
            ('gaming_pc', 120),     # 2 minute warning
            ('ml_training', 300),   # 5 minute warning
            ('non_critical_vms', 300)
        ]
        
        for system, warning_time in shutdown_order:
            print(f"Initiating shutdown of {system} in {warning_time} seconds")
            # Implement actual shutdown logic
```

---

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)

#### Week 1: Hardware Preparation

**Day 1-2: Inventory and Testing**
- [ ] Complete hardware inventory with photos
- [ ] Test all components individually
- [ ] Document serial numbers and firmware versions
- [ ] Create network diagram

**Day 3-4: BIOS/Firmware Updates**
- [ ] Update Cisco UCS firmware
- [ ] Update HP iLO firmware
- [ ] Configure BIOS for GPU passthrough
- [ ] Enable virtualization features

**Day 5-7: Physical Installation**
- [ ] Install cooling for Tesla P40s
- [ ] Cable management
- [ ] Power distribution setup
- [ ] Initial temperature monitoring

#### Week 2: Base Software Installation

**Day 1-2: Hypervisor Setup**
```bash
# Proxmox installation checklist
- [ ] Install on NVMe (NOT SD cards)
- [ ] Configure network bridges
- [ ] Enable IOMMU
- [ ] Join cluster
```

**Day 3-4: Storage Configuration**
```bash
# GlusterFS setup
- [ ] Create ZFS pools
- [ ] Configure Gluster peers
- [ ] Create replicated volumes
- [ ] Mount in Proxmox
```

**Day 5-7: Initial VMs**
```bash
# Core services deployment
- [ ] pfSense firewall VM
- [ ] DNS/DHCP servers
- [ ] Management tools VM
- [ ] Initial backups
```

### Phase 2: Core Services (Weeks 3-4)

#### Week 3: Monitoring and Management

**Prometheus Stack Deployment**
```yaml
# docker-compose.yml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.retention.time=90d'
  
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
      - ./dashboards:/etc/grafana/provisioning/dashboards
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
      - GF_INSTALL_PLUGINS=grafana-piechart-panel,grafana-worldmap-panel
  
  node-exporter:
    image: prom/node-exporter:latest
    network_mode: host
    pid: host
    volumes:
      - /:/host:ro,rslave
    command:
      - '--path.rootfs=/host'

volumes:
  prometheus-data:
  grafana-data:
```

**Custom Dashboards**
```json
// grafana/dashboards/home-lab-overview.json
{
  "dashboard": {
    "title": "Home Lab Overview",
    "panels": [
      {
        "title": "Total Power Consumption",
        "targets": [
          {
            "expr": "sum(pdu_outlet_power_watts)"
          }
        ]
      },
      {
        "title": "GPU Utilization",
        "targets": [
          {
            "expr": "nvidia_gpu_utilization_percentage"
          }
        ]
      },
      {
        "title": "VM Resource Usage",
        "targets": [
          {
            "expr": "sum by (vm_name)(proxmox_vm_cpu_usage)"
          }
        ]
      }
    ]
  }
}
```

#### Week 4: Automation Foundation

**HomeSeer Deployment**
```bash
# Raspberry Pi setup
curl -O https://homeseer.com/updates/hs4_linux_4_2_0_0.tar.gz
tar -xzf hs4_linux_4_2_0_0.tar.gz
cd HomeSeer
sudo ./install.sh

# MQTT plugin configuration
# Install from HS4 plugin manager
# Configure broker: localhost:1883
```

**MQTT Infrastructure**
```yaml
# docker-compose.yml
version: '3.8'
services:
  mosquitto:
    image: eclipse-mosquitto:latest
    ports:
      - "1883:1883"
      - "8883:8883"
    volumes:
      - ./mosquitto.conf:/mosquitto/config/mosquitto.conf
      - mosquitto-data:/mosquitto/data
      - mosquitto-log:/mosquitto/log
  
  mqtt-explorer:
    image: smeagolworms4/mqtt-explorer
    ports:
      - "4000:4000"
    environment:
      - HOST=0.0.0.0

volumes:
  mosquitto-data:
  mosquitto-log:
```

### Phase 3: AI/ML Infrastructure (Weeks 5-6)

#### Week 5: GPU Setup and Testing

**Tesla P40 Configuration**
```bash
# Install NVIDIA drivers
apt-get update
apt-get install -y nvidia-driver-470 nvidia-cuda-toolkit

# Verify GPU detection
nvidia-smi

# Set persistence mode
nvidia-smi -pm 1

# Set power limit (optional)
nvidia-smi -pl 150  # Watts
```

**llama.cpp Deployment**
```dockerfile
# Dockerfile
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone https://github.com/ggerganov/llama.cpp.git
WORKDIR /app/llama.cpp

RUN make clean && make LLAMA_CUBLAS=1 -j$(nproc)

COPY models/ /models/
EXPOSE 8080

CMD ["./server", "-m", "/models/llama-2-13b-chat.Q4_K_M.gguf", "-ngl", "43", "-c", "4096", "--host", "0.0.0.0"]
```

#### Week 6: AI Integration

**AI-Powered Automation Services**
```python
# services/ai_automation_service.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import asyncio
from typing import List, Dict

app = FastAPI()

class AutomationRequest(BaseModel):
    context: str
    sensor_data: Dict[str, float]
    user_preferences: Dict[str, any]

class AutomationResponse(BaseModel):
    actions: List[Dict[str, any]]
    reasoning: str
    confidence: float

@app.post("/analyze", response_model=AutomationResponse)
async def analyze_situation(request: AutomationRequest):
    """
    Analyze current situation and recommend automation actions
    """
    # Process with LLM
    prompt = f"""
    Current context: {request.context}
    Sensor readings: {request.sensor_data}
    User preferences: {request.user_preferences}
    
    Analyze the situation and recommend home automation actions.
    Consider energy efficiency, comfort, and user patterns.
    """
    
    llm_response = await query_llm(prompt)
    
    # Parse LLM response into structured actions
    actions = parse_llm_actions(llm_response)
    
    return AutomationResponse(
        actions=actions,
        reasoning=llm_response['reasoning'],
        confidence=llm_response['confidence']
    )

@app.post("/learn_pattern")
async def learn_user_pattern(data: Dict):
    """
    Learn from user behavior patterns
    """
    # Store in time-series database
    await store_pattern_data(data)
    
    # Retrain models if enough new data
    if await should_retrain():
        asyncio.create_task(retrain_models())
    
    return {"status": "pattern recorded"}
```

### Phase 4: Security & Optimization (Weeks 7-8)

#### Week 7: Security Implementation

**Zero-Trust Network Configuration**
```yaml
# docker-compose.yml for security stack
version: '3.8'
services:
  freeipa:
    image: freeipa/freeipa-server:latest
    hostname: ipa.homelab.local
    environment:
      - IPA_SERVER_HOSTNAME=ipa.homelab.local
      - PASSWORD=admin_password
    volumes:
      - freeipa-data:/data
    ports:
      - "443:443"
      - "389:389"
      - "636:636"
      - "88:88"
      - "464:464"
  
  vault:
    image: vault:latest
    cap_add:
      - IPC_LOCK
    volumes:
      - vault-data:/vault/data
      - ./vault-config:/vault/config
    ports:
      - "8200:8200"
    command: server
  
  suricata:
    image: jasonish/suricata:latest
    network_mode: host
    cap_add:
      - NET_ADMIN
      - SYS_NICE
    volumes:
      - ./suricata/rules:/etc/suricata/rules
      - suricata-logs:/var/log/suricata

volumes:
  freeipa-data:
  vault-data:
  suricata-logs:
```

**API Security Configuration**
```python
# security/api_security.py
from fastapi import Security, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
from datetime import datetime, timedelta

security = HTTPBearer()

class TokenValidator:
    def __init__(self, secret_key, algorithm="HS256"):
        self.secret_key = secret_key
        self.algorithm = algorithm
    
    def create_token(self, user_id: str, scopes: List[str]) -> str:
        payload = {
            "sub": user_id,
            "scopes": scopes,
            "exp": datetime.utcnow() + timedelta(hours=24),
            "iat": datetime.utcnow()
        }
        return jwt.encode(payload, self.secret_key, algorithm=self.algorithm)
    
    def verify_token(self, credentials: HTTPAuthorizationCredentials = Security(security)):
        token = credentials.credentials
        
        try:
            payload = jwt.decode(
                token, 
                self.secret_key, 
                algorithms=[self.algorithm]
            )
            return payload
        except jwt.ExpiredSignatureError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token has expired"
            )
        except jwt.InvalidTokenError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )
```

#### Week 8: Performance Optimization

**System Tuning**
```bash
#!/bin/bash
# system_tuning.sh

# CPU Performance Governor
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo "performance" > $cpu
done

# Disable CPU frequency scaling
systemctl disable ondemand

# Network optimization
cat >> /etc/sysctl.conf << EOF
# Network performance tuning
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_congestion_control = bbr
EOF

# Storage optimization for NVMe
echo 'none' > /sys/block/nvme0n1/queue/scheduler
echo '256' > /sys/block/nvme0n1/queue/nr_requests

# GPU optimization
nvidia-smi -pm 1  # Persistence mode
nvidia-smi -ac 715,1380  # Application clocks for P40
```

**Performance Monitoring**
```python
# monitoring/performance_monitor.py
import psutil
import GPUtil
from prometheus_client import Gauge, start_http_server
import time

# Define metrics
cpu_usage = Gauge('homelab_cpu_usage_percent', 'CPU usage percentage', ['host', 'cpu'])
memory_usage = Gauge('homelab_memory_usage_percent', 'Memory usage percentage', ['host'])
gpu_usage = Gauge('homelab_gpu_usage_percent', 'GPU usage percentage', ['host', 'gpu'])
gpu_memory = Gauge('homelab_gpu_memory_used_mb', 'GPU memory used in MB', ['host', 'gpu'])
disk_io = Gauge('homelab_disk_io_mbps', 'Disk I/O in MB/s', ['host', 'disk', 'direction'])
network_io = Gauge('homelab_network_io_mbps', 'Network I/O in MB/s', ['host', 'interface', 'direction'])

def collect_metrics():
    hostname = socket.gethostname()
    
    # CPU metrics
    cpu_percent = psutil.cpu_percent(interval=1, percpu=True)
    for i, percent in enumerate(cpu_percent):
        cpu_usage.labels(host=hostname, cpu=f'cpu{i}').set(percent)
    
    # Memory metrics
    memory = psutil.virtual_memory()
    memory_usage.labels(host=hostname).set(memory.percent)
    
    # GPU metrics
    gpus = GPUtil.getGPUs()
    for i, gpu in enumerate(gpus):
        gpu_usage.labels(host=hostname, gpu=f'gpu{i}').set(gpu.load * 100)
        gpu_memory.labels(host=hostname, gpu=f'gpu{i}').set(gpu.memoryUsed)
    
    # Disk I/O
    disk_counters = psutil.disk_io_counters(perdisk=True)
    for disk, counters in disk_counters.items():
        disk_io.labels(host=hostname, disk=disk, direction='read').set(
            counters.read_bytes / 1024 / 1024
        )
        disk_io.labels(host=hostname, disk=disk, direction='write').set(
            counters.write_bytes / 1024 / 1024
        )

if __name__ == '__main__':
    # Start Prometheus metrics server
    start_http_server(9200)
    
    while True:
        collect_metrics()
        time.sleep(10)
```

---

## Operations Guide

### Daily Operations Checklist

```yaml
# daily_ops_checklist.yml
daily_tasks:
  monitoring:
    - check_grafana_dashboards:
        alerts: ["temperature", "disk_space", "memory_pressure"]
    - review_logs:
        sources: ["proxmox", "docker", "homeseer"]
    - verify_backups:
        check_last_run: true
        verify_integrity: true
  
  maintenance:
    - update_check:
        systems: ["proxmox", "docker_images", "homeseer_plugins"]
    - resource_cleanup:
        - docker_prune: true
        - log_rotation: true
        - temp_files: true
  
  security:
    - review_auth_logs: true
    - check_firewall_denies: true
    - verify_certificates:
        days_before_expiry: 30
```

### Backup Strategy

#### 3-2-1 Backup Rule Implementation

```yaml
# backup_strategy.yml
backup_configuration:
  primary:
    tool: "Proxmox Backup Server"
    schedule: "0 2 * * *"  # 2 AM daily
    retention:
      daily: 7
      weekly: 4
      monthly: 12
    targets:
      - all_vms
      - all_containers
  
  secondary:
    tool: "Borg Backup"
    schedule: "0 4 * * *"  # 4 AM daily
    encryption: true
    deduplication: true
    targets:
      - /etc
      - /opt
      - /home
      - /var/lib/docker/volumes
  
  offsite:
    tool: "Rclone"
    destination: "backblaze_b2"
    schedule: "0 6 * * 0"  # Sunday 6 AM
    encryption: true
    bandwidth_limit: "10M"
```

#### Backup Script

```bash
#!/bin/bash
# backup_manager.sh

# Load configuration
source /etc/backup/config.env

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $BACKUP_LOG
}

# Proxmox VM backups
backup_vms() {
    log "Starting VM backups..."
    
    for vm_id in $(pvesh get /cluster/resources --type vm --output-format json | jq -r '.[].vmid'); do
        log "Backing up VM $vm_id"
        vzdump $vm_id --storage $BACKUP_STORAGE --mode snapshot --compress zstd
    done
}

# Application data backups
backup_app_data() {
    log "Starting application data backup..."
    
    # Docker volumes
    docker run --rm \
        -v /var/lib/docker/volumes:/volumes:ro \
        -v $BORG_REPO:/repo \
        borgbackup/borg create \
        --compression zstd,9 \
        --exclude-caches \
        ::{hostname}-{now} /volumes
}

# Configuration backups
backup_configs() {
    log "Starting configuration backup..."
    
    # Create config archive
    tar czf /tmp/configs-$(date +%Y%m%d).tar.gz \
        /etc/proxmox \
        /etc/docker \
        /etc/ansible \
        /opt/homeseer/Config
    
    # Upload to object storage
    rclone copy /tmp/configs-*.tar.gz remote:homelab-backups/configs/
}

# Verify backups
verify_backups() {
    log "Verifying backups..."
    
    # Check Borg repository
    docker run --rm \
        -v $BORG_REPO:/repo \
        borgbackup/borg check --verify-data
    
    # Check Proxmox backups
    pvesm list $BACKUP_STORAGE --vmid all
}

# Main execution
main() {
    log "=== Backup job started ==="
    
    backup_vms
    backup_app_data
    backup_configs
    verify_backups
