#!/bin/bash

# Main logic of the script
check_node_status() {
    cd ~/.shardeum && ./shell.sh && operator-cli status > /tmp/shardeum_status_$SERVER_NAME.txt

    # Read the content of the status file
    status=$(cat /tmp/shardeum_status_$SERVER_NAME.txt)

    # Check if the status was not found
    if [ -z "$status" ]; then
        status="ERROR"
    fi
}

# Check the node status
check_node_status

# Format the message for Telegram
message="Server #: $SERVER_NAME\nIP: $(hostname -I | awk '{print $1}')\nStatus:\n$status"

# Send the message to Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$message"
