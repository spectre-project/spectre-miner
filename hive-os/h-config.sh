#!/usr/bin/env bash
set -x

# Extract the dynamic part (assuming 'nproc' command is your dynamic part)
DYNAMIC_PART=$(echo "$CUSTOM_USER_CONFIG" | grep -oP '\$\((nproc.*)\)')

if [ ! -z "$DYNAMIC_PART" ]; then
    EVALUATED_DYNAMIC_PART=$(eval echo "$DYNAMIC_PART")
    eval echo "$DYNAMIC_PART" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        SAFE_DYNAMIC_PART=$(printf '%s\n' "$DYNAMIC_PART" | sed 's:[][\/.^$*]:\\&:g')
        MODIFIED_CONFIG=$(echo "$CUSTOM_USER_CONFIG" | sed "s/$SAFE_DYNAMIC_PART/$EVALUATED_DYNAMIC_PART/")
        conf="$MODIFIED_CONFIG"
        echo "Modified config after removing executed command: $conf"
    else
        echo "Error in executing dynamic part. No modifications made."
        conf="$CUSTOM_USER_CONFIG"
    fi
else
    echo "No dynamic part found. No modifications made."
    conf="$CUSTOM_USER_CONFIG"
fi

echo "$conf"
echo "$conf" > "$CUSTOM_CONFIG_FILENAME"

echo "Wrote config to $CUSTOM_CONFIG_FILENAME"
echo "The contents of the config file are:"
cat "$CUSTOM_CONFIG_FILENAME"