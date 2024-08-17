#!/bin/bash

# Встановлення змінних
INSTALL_DIR="$HOME/shardeum_tg_checker"
SCRIPT_NAME="check_shardeum_status.sh"
CRON_FILE="$HOME/crontab_backup"

# Створення директорії
mkdir -p "$INSTALL_DIR"

# Завантаження скрипту з GitHub
wget -O "$INSTALL_DIR/$SCRIPT_NAME" https://github.com/Marchkkkk/shardeum_tg_checker/raw/main/$SCRIPT_NAME
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

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
