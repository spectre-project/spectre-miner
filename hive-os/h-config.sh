#!/usr/bin/env bash
#conf="$CUSTOM_USER_CONFIG"
set -x

#
# Doing some magic here
#
# Example configuration
##CUSTOM_USER_CONFIG='-arch -t $(nvtool) -i SUVSIJWDQURNJCAFVNRBUQNDOKGAGKOJYUAEINDKEFKPCMQPQDCUMFMBCQSJ --label rig1'

# Extract the dynamic part (assuming 'nproc' command is your dynamic part)
DYNAMIC_PART=$(echo "$CUSTOM_USER_CONFIG" | grep -oP '\$\((nproc.*)\)')

# Check if the dynamic part was successfully extracted
if [ ! -z "$DYNAMIC_PART" ]; then
    # Evaluate the dynamic part to get its actual value
    EVALUATED_DYNAMIC_PART=$(eval echo "$DYNAMIC_PART")
    eval echo "$DYNAMIC_PART" > /dev/null 2>&1

    # If you still need to remove the dynamic command from the config, not just execute it
    if [ $? -eq 0 ]; then  # Checks if the command was successful
        # Prepare a version of DYNAMIC_PART that is safe for use in sed
        SAFE_DYNAMIC_PART=$(printf '%s\n' "$DYNAMIC_PART" | sed 's:[][\/.^$*]:\\&:g')

	 # Now, replace the dynamic part with its evaluated output
        MODIFIED_CONFIG=$(echo "$CUSTOM_USER_CONFIG" | sed "s/$SAFE_DYNAMIC_PART/$EVALUATED_DYNAMIC_PART/")


        # Output the modified configuration without the executed command
        echo "Modified config after removing executed command: $MODIFIED_CONFIG"
        conf="$MODIFIED_CONFIG"
    else
        echo "Error in executing dynamic part. No modifications made."
        conf="$CUSTOM_USER_CONFIG"
    fi
else
    echo "No dynamic part found. No modifications made."
    conf="$CUSTOM_USER_CONFIG"
fi

echo "$conf"
echo "$conf" > $CUSTOM_CONFIG_FILENAME

echo "wrote config to $CUSTOM_CONFIG_FILENAME"
echo "The contents of the config file are: $(<$CUSTOM_CONFIG_FILENAME)"

