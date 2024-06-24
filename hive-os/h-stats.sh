#!/usr/bin/env bash
source /hive/miners/custom/spectre-miner/h-manifest.conf

log=$(cat /var/log/miner/custom/custom.log)

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

get_uptime() {
  local start_time=$(head /var/log/miner/custom/custom.log -n1 | cut -c 2-21)
  local start_seconds=$(date -d"$start_time" +%s)
  local current_seconds=$(date +%s)
  echo $((current_seconds - start_seconds))
}

uptime=$(get_uptime)

total_khs=$(echo $log | grep -oP "hashrate is: \K\d+.\d+" | tail -n1)
ac=$(echo $log | grep -coP "Block submitted successfully!")
rj=0
ver=$CUSTOM_VERSION
algo="astrobwt"
cpu_temp=$(/hive/sbin/cpu-temp)
hs_units="hs"

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

echo khs:   $hs
echo stats: $stats
echo ----------