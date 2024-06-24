#!/usr/bin/env bash

# Source the configuration file
source h-manifest.conf

# Define the custom log directory
LOG_DIR=$(dirname "$CUSTOM_LOG_BASENAME")
mkdir -p "$LOG_DIR"

# Check if the custom config filename is defined
if [[ -z ${CUSTOM_CONFIG_FILENAME:-} ]]; then
    echo "The config file is not defined"
    exit 1
fi

# Set the library path
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/hive/lib

# Read the custom user configuration
CUSTOM_USER_CONFIG=$(< "$CUSTOM_CONFIG_FILENAME")

# Display the arguments
echo "args: $CUSTOM_USER_CONFIG"

MINER=spectre-miner

# Remove the -arch argument and its value
CLEAN=$(echo "$CUSTOM_USER_CONFIG" | sed -E 's/-arch [^ ]+ //')
echo "args are now: $CLEAN"
echo "We are using miner: $MINER"

echo $(date +%s) > "/tmp/miner_start_time"
/hive/miners/custom/$MINER/$MINER $CLEAN 2>&1 | tee -a ${CUSTOM_LOG_BASENAME}.log
echo "Miner has exited"