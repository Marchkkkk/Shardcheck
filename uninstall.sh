#!/bin/bash

# Define installation directory
INSTALL_DIR="/root/shard_tg_checker"

# Remove the cron job
crontab -l | grep -v "$INSTALL_DIR/check_shardeum_status.sh" | crontab -

# Remove the script directory
rm -rf $INSTALL_DIR

echo "Script and all its components have been removed."
