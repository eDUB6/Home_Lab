#!/bin/bash

# HP ML350 Gen9 GPU-Based Fan Control Script
# Automatically adjusts server fans based on Tesla P40 temperatures
# Run this alongside your stress tests for optimal cooling

# Configuration
LOG_FILE="ml350_fan_control_$(date +%Y%m%d_%H%M%S).log"
CHECK_INTERVAL=30       # Check temperature every 30 seconds
TEMP_HIGH=75            # High temperature threshold
TEMP_MEDIUM=65          # Medium temperature threshold
TEMP_LOW=55             # Low temperature threshold
MAX_TEMP_EMERGENCY=85   # Emergency temperature (force max fans)

# Fan speed values (0x00 to 0x64 = 0% to 100%)
FAN_SPEED_MAX=0x64        # 100%
FAN_SPEED_80_PERCENT=0x50 # ~80%
FAN_SPEED_MEDIUM=0x40     # ~60%
FAN_SPEED_LOW=0x30        # ~45%
FAN_SPEED_AUTO=0x00       # Auto mode

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Current fan mode tracking
CURRENT_MODE="unknown"

# Function to log with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check if nvidia-smi is available and working
check_nvidia_smi() {
    if ! command -v nvidia-smi &> /dev/null; then
        echo -e "${RED}nvidia-smi not found!${NC}"
        return 1
    fi
    if ! nvidia-smi -L &>/dev/null; then
        echo -e "${RED}nvidia-smi cannot access GPU data!${NC}"
        return 1
    fi
    log_message "✅ nvidia-smi working"
    return 0
}

# Function to check if ipmitool is available and has required privileges
check_ipmi_privileges() {
    if ! command -v ipmitool &> /dev/null; then
        echo -e "${RED}ipmitool not found!${NC}"
        return 1
    fi
    if ! ipmitool raw 0x30 0x30 0x01 0x00 &>/dev/null; then
        echo -e "${RED}IPMI raw commands failed! Requires sudo.${NC}"
        return 1
    fi
    log_message "✅ IPMI raw commands working"
    return 0
}

# Function to set fan speed
set_fan_speed() {
    local speed=$1
    local mode_name=$2
    if [ "$CURRENT_MODE" != "$mode_name" ]; then
        log_message " Setting fans to $mode_name mode (speed: $speed)"
        ipmitool raw 0x30 0x30 0x02 0xff "$speed" &>/dev/null
        CURRENT_MODE="$mode_name"
    fi
}

# Function to set fans back to automatic mode
set_auto_mode() {
    if [ "$CURRENT_MODE" != "auto" ]; then
        log_message " Returning fans to automatic control"
        ipmitool raw 0x30 0x30 0x01 0x00 &>/dev/null
        CURRENT_MODE="auto"
    fi
}

# Function to get maximum GPU temperature
get_max_gpu_temp() {
    nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | sort -nr | head -1
}

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Returning fans to automatic control...${NC}"
    set_auto_mode
    log_message "Fan control returned to automatic mode. Script stopped."
    exit 0
}

# Trap signals for cleanup
trap cleanup SIGINT SIGTERM SIGQUIT

# Main function
main() {
    log_message "Starting HP ML350 Gen9 GPU-based fan control"
    if ! check_nvidia_smi || ! check_ipmi_privileges; then
        exit 1
    fi
    
    echo "Fan control active. Press Ctrl+C to stop."

    while true; do
        max_temp=$(get_max_gpu_temp)
        
        if [ "$max_temp" -ge "$MAX_TEMP_EMERGENCY" ]; then
            set_fan_speed "$FAN_SPEED_MAX" "EMERGENCY"
        elif [ "$max_temp" -ge "$TEMP_HIGH" ]; then
            set_fan_speed "$FAN_SPEED_MAX" "HIGH"
        elif [ "$max_temp" -ge "$TEMP_MEDIUM" ]; then
            set_fan_speed "$FAN_SPEED_80_PERCENT" "MEDIUM-HIGH"
        elif [ "$max_temp" -ge "$TEMP_LOW" ]; then
            set_fan_speed "$FAN_SPEED_MEDIUM" "MEDIUM"
        else
            set_fan_speed "$FAN_SPEED_LOW" "LOW"
        fi
        
        log_message "GPU Temp: ${max_temp}°C, Fan Mode: $CURRENT_MODE"
        sleep "$CHECK_INTERVAL"
    done
}

main
