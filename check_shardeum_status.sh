#!/bin/bash

# Завантаження конфігурації
source "$HOME/shardeum_tg_checker/config.sh"

# Функція для перевірки статусу ноди
check_node_status() {
    # Перехід до директорії і виконання shell.sh
    if ! cd ~/.shardeum || ! ./shell.sh; then
        echo "Не вдалося перейти до директорії або виконати shell.sh"
        return 1
    fi
    
    # Отримання статусу ноди
    if ! status=$(operator-cli status 2>&1 | grep "status: " | awk '{print $2}'); then
        echo "Не вдалося отримати статус ноди"
        return 1
    fi

    return 0
}

# Перевірка статусу ноди
if ! check_node_status; then
    # Формування повідомлення про помилку для Telegram
    message="Сервер №: $SERVER_NAME\nIP: $(hostname -I | awk '{print $1}')\nСтатус: Error"

    # Надсилання повідомлення в Telegram
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$message"

    echo "Повідомлення про помилку надіслано в Telegram."
    exit 1
fi

# Формування повідомлення для Telegram
message="Сервер №: $SERVER_NAME\nIP: $(hostname -I | awk '{print $1}')\nСтатус: $status"

# Надсилання повідомлення в Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$message"

echo "Повідомлення надіслано в Telegram."
