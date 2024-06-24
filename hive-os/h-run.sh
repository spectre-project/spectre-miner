#!/usr/bin/env bash

source h-manifest.conf

CUSTOM_LOG_BASEDIR=$(dirname "$CUSTOM_LOG_BASENAME")
[[ ! -d $CUSTOM_LOG_BASEDIR ]] && mkdir -p $CUSTOM_LOG_BASEDIR

if [[ -z $CUSTOM_CONFIG_FILENAME ]]; then
    echo -e "The config file is not defined"
    exit 1
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/hive/lib

CUSTOM_USER_CONFIG=$(< "$CUSTOM_CONFIG_FILENAME")

echo "args: $CUSTOM_USER_CONFIG"

MINER=spectre-miner

# Remove the -arch argument and its value
CLEAN=$(echo "$CUSTOM_USER_CONFIG" | sed -E 's/-arch [^ ]+ //')
echo "args are now: $CLEAN"
echo "We are using miner: $MINER"

echo $(date +%s) > "/tmp/miner_start_time"
/hive/miners/custom/$MINER/$MINER $CLEAN 2>&1 | tee -a ${CUSTOM_LOG_BASENAME}.log
echo "Miner has exited"