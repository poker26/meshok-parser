#!/bin/bash

# Скрипт настройки автоматического мониторинга сервера

echo "🔧 Настройка автоматического мониторинга сервера..."

# Создаем директорию для логов
mkdir -p /var/log

# Делаем скрипт исполняемым
chmod +x auto-restart.sh

# Добавляем в cron задачу проверки каждые 5 минут
echo "📅 Настройка cron задачи..."

# Создаем временный файл с cron задачей
cat > /tmp/wolmar-monitor-cron << EOF
# Автоматический мониторинг сервера wolmar-parser
# Проверка каждые 5 минут
*/5 * * * * /var/www/wolmar-parser/auto-restart.sh

# Ежедневная очистка логов (старше 7 дней)
0 2 * * * find /var/log -name "wolmar-auto-restart.log*" -mtime +7 -delete
EOF

# Добавляем задачу в cron (если её еще нет)
if ! crontab -l 2>/dev/null | grep -q "wolmar-parser/auto-restart.sh"; then
    (crontab -l 2>/dev/null; cat /tmp/wolmar-monitor-cron) | crontab -
    echo "✅ Cron задача добавлена"
else
    echo "⚠️ Cron задача уже существует"
fi

# Удаляем временный файл
rm /tmp/wolmar-monitor-cron

echo "🎯 Настройка завершена!"
echo ""
echo "📋 Что настроено:"
echo "  • Проверка сервера каждые 5 минут"
echo "  • Автоматический перезапуск при сбоях"
echo "  • Логирование в /var/log/wolmar-auto-restart.log"
echo "  • Очистка старых логов"
echo ""
echo "🔍 Проверить cron задачи: crontab -l"
echo "📊 Посмотреть логи: tail -f /var/log/wolmar-auto-restart.log"
echo "🛑 Остановить мониторинг: crontab -e (удалить строку с auto-restart.sh)"
