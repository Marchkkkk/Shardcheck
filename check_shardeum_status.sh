#!/bin/bash

# Define necessary variables
SERVER_NAME="YourServerName"
BOT_TOKEN="YourBotToken"
CHAT_ID="YourChatID"

# Function to check node status and send it to Telegram
check_node_status() {
    # Navigate to the Shardeum directory and run the command
    cd ~/.shardeum || { echo "Failed to navigate to ~/.shardeum"; exit 1; }
    ./shell.sh
    operator-cli status > /tmp/shardeum_status_$SERVER_NAME.txt

    # Check if the file was created and contains data
    if [ ! -s /tmp/shardeum_status_$SERVER_NAME.txt ]; then
        status="ERROR: Status file is empty or does not exist."
    else
        # Read the entire content of the status file
        status=$(cat /tmp/shardeum_status_$SERVER_NAME.txt)
    fi
}

# Execute the function
check_node_status

# Format the message for Telegram
message="Server #: $SERVER_NAME\nIP: $(hostname -I | awk '{print $1}')\nStatus:\n$status"

# Send the message to Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$message"
