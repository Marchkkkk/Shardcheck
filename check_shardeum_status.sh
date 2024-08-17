#!/bin/bash

# Отримання директорії, в якій розміщено цей скрипт
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Завантаження конфігурації
source "$SCRIPT_DIR/config.sh"

# Файл для зберігання логу статусу ноди
STATUS_LOG="$SCRIPT_DIR/status_output.txt"

# Функція для перевірки статусу ноди
check_node_status() {
    # Перехід до директорії і виконання shell.sh
    if ! cd ~/.shardeum || ! ./shell.sh; then
        echo "Не вдалося перейти до директорії або виконати shell.sh" >> "$STATUS_LOG"
        return 1
    fi

    # Додати невелику затримку для впевненості, що середовище готове
    sleep 5

    # Отримання статусу ноди та запис всього вихідного результату у файл для відлагодження
    full_output=$(operator-cli status 2>&1)
    echo "$full_output" > "$STATUS_LOG"

    # Виведення відлагоджувальної інформації в консоль
    echo "Отриманий вихідний результат:"
    echo "$full_output"

    # Спроба знайти статус в отриманому результаті
    status=$(echo "$full_output" | grep "state:" | awk '{print $2}')
    if [ -z "$status" ]; then
        echo "Не вдалося отримати статус ноди" >> "$STATUS_LOG"
        return 1
    fi

    return 0
}

# Перевірка статусу ноди
if ! check_node_status; then
    # Формування повідомлення про помилку для Telegram
    message="Сервер №: $SERVER_NAME%0AIP: $(hostname -I | awk '{print $1}')%0AСтатус: Error"

    # Надсилання повідомлення в Telegram
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$message"

    echo "Повідомлення про помилку надіслано в Telegram." >> "$STATUS_LOG"
    exit 1
fi

# Формування повідомлення для Telegram
message="Сервер №: $SERVER_NAME%0AIP: $(hostname -I | awk '{print $1}')%0AСтатус: $status"

# Надсилання повідомлення в Telegram
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$message"

echo "Повідомлення надіслано в Telegram." >> "$STATUS_LOG"
