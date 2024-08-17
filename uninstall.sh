#!/bin/bash

# Remove the cron job
crontab -l | grep -v "/usr/local/shardeum_status/check_shardeum_status.sh" | crontab -

# Remove the script directory
rm -rf /usr/local/shardeum_status

echo "Script and all its components have been removed."
