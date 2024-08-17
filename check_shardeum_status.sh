#!/bin/bash

# Завантаження конфігурації
source "$HOME/shardeum_tg_checker/config.sh"

# Основна логіка скрипта
check_node_status() {
    cd ~/.shardeum && ./shell.sh && operator-cli status > /tmp/shardeum_status_$SERVER_NAME.txt

    status=$(grep "status: " /tmp/shardeum_status_$SERVER_NAME.txt | awk '{print $2}')
}

# Перевірка статусу ноди
check_node_status

# Формування повідомлення для Telegram
message="Сервер №: $SERVER_NAME\nIP: $(hostname -I | awk '{print $1}')\nСтатус: $status"

# Надсилання повідомлення в Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$message"

echo "Повідомлення надіслано в Telegram."
