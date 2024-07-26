#!/usr/bin/env bash
source /hive/miners/custom/spectre-miner/h-manifest.conf

# Reading log file content
log_file="/var/log/miner/custom/custom.log"

# Read the log file content
log=$(<"$log_file")

get_cpu_temps () {
  local t_core=$(cpu-temp)
  local l_num_cores=$1
  local l_temp=
  for (( i=0; i < l_num_cores; i++ )); do
    l_temp+="$t_core "
  done
  echo $l_temp | tr " " "\n" | jq -cs '.'
}

get_cpu_fans () {
  local t_fan=0
  local l_num_cores=$1
  local l_fan=
  for (( i=0; i < l_num_cores; i++ )); do
    l_fan+="$t_fan "
  done
  echo $l_fan | tr " " "\n" | jq -cs '.'
}

get_uptime(){
    local start_time=$(cat "/tmp/miner_start_time")
    local current_time=$(date +%s)
    let uptime=current_time-start_time
    echo $uptime
}

uptime=$(get_uptime)

# Extract the most recent total khs value from the log
total_khs=$(grep -oP "hashrate is: \K\d+.\d+" <<< "$log" | tail -n1)
if [[ -z $total_khs ]]; then
  total_khs=0
fi

# Count the number of blocks submitted successfully
ac=$(grep -coP "Block submitted successfully!" <<< "$log")
if [[ -z $ac ]]; then
  ac=0
fi

rj=0
ver="custom"
algo="spectrex"
cpu_temp=$(/hive/sbin/cpu-temp)
hs_units="hs"

# Construct JSON stats
stats=$(jq -nc \
        --arg total_khs "$total_khs" \
        --arg khs "$total_khs" \
        --arg hs_units "$hs_units" \
        --arg hs "[$total_khs]" \
        --arg temp "[$cpu_temp]" \
        --arg uptime "$uptime" \
        --arg ver "$ver" \
        --argjson ac "$ac" \
        --argjson rj "$rj" \
        --arg algo "$algo" \
        '{$total_khs, $khs, $hs_units, $hs, $temp, $uptime, $ver, ar: [$ac, $rj], $algo }')

echo "khs:   $hs"
echo "stats: $stats"
echo "----------"
