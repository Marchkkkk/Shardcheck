#!/bin/bash

# Define file paths
STATUS_FILE="/tmp/shardeum_status.txt"
DEBUG_LOG="/tmp/debug_log.txt"

# Function to check node status
check_node_status() {
    cd ~/.shardeum || exit
    ./shell.sh > "$DEBUG_LOG" 2>&1
    operator-cli status > "$STATUS_FILE"
}

# Check the node status
check_node_status

# Extract the status value
status=$(grep "state: " "$STATUS_FILE" | awk '{print $2}')

# If status is empty, set to ERROR
if [ -z "$status" ]; then
    status="ERROR"
fi

# Get the server IP address
ip_address=$(hostname -I | awk '{print $1}')

# Format the message for Telegram
message="Server #: $SERVER_NAME\nIP: $ip_address\nStatus: $status"

# Send the message to Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
     -d chat_id="$CHAT_ID" \
     -d text="$message"

# Optional: Output for debugging
echo "Sent message: $message" >> "$DEBUG_LOG"
