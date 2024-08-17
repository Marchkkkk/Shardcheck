#!/bin/bash

# Встановлення змінних
INSTALL_DIR="$HOME/shardeum_tg_checker"
SCRIPT_NAME="check_shardeum_status.sh"
CONFIG_FILE="$INSTALL_DIR/config.sh"
CRON_FILE="$HOME/crontab_backup"

# Перевірка наявності wget або curl для завантаження файлів
if command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget -q"
elif command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl -sL"
else
    echo "Помилка: wget або curl не знайдено. Встановіть один з них для продовження."
    exit 1
fi

# Створення директорії для скриптів
mkdir -p "$INSTALL_DIR"

# Завантаження скриптів з GitHub
$DOWNLOAD_CMD https://github.com/Marchkkkk/shardeum_tg_checker/raw/main/$SCRIPT_NAME -o "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Запит параметрів конфігурації
echo "Введіть дані для налаштування скрипту:"
read -p "BOT_TOKEN: " BOT_TOKEN
read -p "CHAT_ID: " CHAT_ID
read -p "SERVER_NAME: " SERVER_NAME

# Створення файлу конфігурації
cat <<EOL > "$CONFIG_FILE"
# Конфігурація для Telegram
BOT_TOKEN="$BOT_TOKEN"
CHAT_ID="$CHAT_ID"
SERVER_NAME="$SERVER_NAME"
EOL

echo "Файл конфігурації створено за адресою $CONFIG_FILE."

# Запит частоти виконання
echo "Виберіть частоту виконання (введіть цифру):"
echo "1. Кожні 3 хвилини"
echo "2. Кожну годину"
echo "3. Кожні 3 години"
read -p "Введіть номер опції [1-3]: " OPTION

# Видалення старих cron завдань
crontab -l > "$CRON_FILE"
grep -v "$SCRIPT_NAME" "$CRON_FILE" | crontab -

# Налаштування нового cron завдання
case $OPTION in
    1)
        CRON_EXPR="*/3 * * * *"
        ;;
    2)
        CRON_EXPR="0 * * * *"
        ;;
    3)
        CRON_EXPR="0 */3 * * *"
        ;;
    *)
        echo "Невірний вибір. Використовується за замовчуванням (кожну годину)."
        CRON_EXPR="0 * * * *"
        ;;
esac

# Додавання нового cron завдання
echo "$CRON_EXPR /bin/bash $INSTALL_DIR/$SCRIPT_NAME" >> "$CRON_FILE"
crontab "$CRON_FILE"
rm "$CRON_FILE"

echo "Скрипт встановлено і налаштовано для виконання $CRON_EXPR."
