#!/bin/bash

# Функція для створення директорії та завантаження файлів
setup_environment() {
    # Створення директорії для скрипта
    SCRIPT_DIR="$HOME/shardeum_tg_checker"
    mkdir -p $SCRIPT_DIR

    # Перехід у створену директорію
    cd $SCRIPT_DIR

    # Завантаження основного скрипта з GitHub
    echo "Завантаження основного скрипта з GitHub..."
    curl -s -o check_shardeum_status.sh https://raw.githubusercontent.com/Marchkkkk/shardeum_tg_checker/main/check_shardeum_status.sh

    # Надання прав на виконання
    chmod +x check_shardeum_status.sh
}

# Функція для налаштування cron
setup_cron() {
    CRON_JOB="0 * * * * $SCRIPT_DIR/check_shardeum_status.sh"
    
    # Перевірка наявності cron
    (crontab -l 2>/dev/null | grep -v -F "$SCRIPT_DIR/check_shardeum_status.sh"; echo "$CRON_JOB") | crontab -
    
    echo "Cron налаштовано для щогодинного виконання скрипта."
}

# Функція для запиту даних у користувача
get_user_input() {
    read -p "Введіть ім'я сервера: " SERVER_NAME
    read -p "Введіть ваш Telegram BOT_TOKEN: " BOT_TOKEN
    read -p "Введіть ваш Telegram CHAT_ID: " CHAT_ID

    # Запис даних у конфігураційний файл
    echo "SERVER_NAME=\"$SERVER_NAME\"" > $SCRIPT_DIR/config.sh
    echo "BOT_TOKEN=\"$BOT_TOKEN\"" >> $SCRIPT_DIR/config.sh
    echo "CHAT_ID=\"$CHAT_ID\"" >> $SCRIPT_DIR/config.sh
}

# Основна частина скрипта
setup_environment
get_user_input
setup_cron

echo "Інсталяція завершена. Ви можете запустити основний скрипт вручну за допомогою: $SCRIPT_DIR/check_shardeum_status.sh"
