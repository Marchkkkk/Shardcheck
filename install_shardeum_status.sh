#!/bin/bash

# Create a directory for the script
INSTALL_DIR="/usr/local/shardeum_status"
mkdir -p $INSTALL_DIR

# Ask the user for necessary information
read -p "Enter server name: " SERVER_NAME
read -p "Enter your Telegram BOT_TOKEN: " BOT_TOKEN
read -p "Enter your Telegram CHAT_ID: " CHAT_ID

# Ask the user for the status update frequency
echo "Choose the frequency for sending status updates to Telegram:"
echo "1) Every 3 minutes"
echo "2) Every hour"
echo "3) Every 2 hours"
echo "4) Every 5 hours"
read -p "Your choice (1-4): " INTERVAL_CHOICE

# Convert the user's choice into a cron format
case $INTERVAL_CHOICE in
    1) CRON_SCHEDULE="*/3 * * * *" ;;  # Every 3 minutes
    2) CRON_SCHEDULE="0 * * * *" ;;    # Every hour
    3) CRON_SCHEDULE="0 */2 * * *" ;;  # Every 2 hours
    4) CRON_SCHEDULE="0 */5 * * *" ;;  # Every 5 hours
    *) echo "Invalid choice. Installation canceled." ; exit 1 ;;
esac

# Create the main script for checking the status
cat <<EOL > $INSTALL_DIR/check_shardeum_status.sh
#!/bin/bash

# Main logic of the script
check_node_status() {
    cd ~/.shardeum && ./shell.sh && operator-cli status > /tmp/shardeum_status_\$SERVER_NAME.txt

    status=\$(grep "status: " /tmp/shardeum_status_\$SERVER_NAME.txt | awk '{print \$2}')
    
    # Check if the status was not found
    if [ -z "\$status" ]; then
        status="ERROR"
    fi
}

# Check the node status
check_node_status

# Format the message for Telegram
message="Server #: $SERVER_NAME\nIP: \$(hostname -I | awk '{print \$1}')\nStatus: \$status"

# Send the message to Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="\$message"
EOL

# Grant execution rights to the script
chmod +x $INSTALL_DIR/check_shardeum_status.sh

# Add the task to cron
(crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $INSTALL_DIR/check_shardeum_status.sh") | crontab -

echo "Installation completed. The script will run according to the schedule: $CRON_SCHEDULE"

# Create a script for uninstallation
cat <<EOL > $INSTALL_DIR/uninstall.sh
#!/bin/bash

# Remove the cron job
crontab -l | grep -v "$INSTALL_DIR/check_shardeum_status.sh" | crontab -

# Remove the script directory
rm -rf $INSTALL_DIR

echo "Script and all its components have been removed."
EOL

# Grant execution rights to the uninstall script
chmod +x $INSTALL_DIR/uninstall.sh

echo "To uninstall the script, run: $INSTALL_DIR/uninstall.sh"
