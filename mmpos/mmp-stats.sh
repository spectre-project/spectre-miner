#!/usr/bin/env bash
GPU_COUNT=$1
LOG_FILE=$2
cd `dirname $0`
[ -r mmp-external.conf ] && . mmp-external.conf

get_cpu_hashes() {
    hash=''
    local hs=$(grep -oP "hashrate is: \K\d+.\d+" <<< $(cat $LOG_FILE) | tail -n1)
    if [[ -z "$hs" ]]; then
        hs="0"
    fi
    if [[ $hs > 0 ]]; then
        hash=$(echo "$hs")
    fi
}

get_miner_stats() {
    stats=
    local hash=
    get_cpu_hashes
    # A/R shares by pool
    local acc=$(grep -coP "Block submitted successfully!" <<< $(cat $LOG_FILE))
    # local inv=$(get_miner_shares_inv)
    # local rj=$(get_miner_shares_rj)

    stats=$(jq -nc \
            --argjson hash "$(echo "${hash[@]}" | tr " " "\n" | jq -cs '.')" \
            --arg busid "cpu" \
            --arg units "khs" \
            --arg ac "$acc" --arg inv "0" --arg rj "0" \
            --arg miner_version "$EXTERNAL_VERSION" \
            --arg miner_name "$EXTERNAL_NAME" \
        '{busid: [$busid], $hash, $units, air: [$ac, $inv, $rj], miner_name: $miner_name, miner_version: $miner_version}')
    echo "$stats"
}
get_miner_stats