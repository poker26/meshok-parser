#!/bin/bash

# Скрипт для обновления сервера wolmar-parser
# Автоматически выполняет: git pull, pm2 restart, проверку статуса

echo "🚀 Обновление сервера wolmar-parser..."
echo "=================================="

# Проверяем, что мы в правильной директории
if [ ! -f "server.js" ]; then
    echo "❌ Ошибка: Скрипт должен запускаться из директории wolmar-parser"
    echo "💡 Перейдите в директорию: cd /var/www/wolmar-parser"
    exit 1
fi

# Показываем текущий статус
echo "📊 Текущий статус PM2:"
pm2 status

echo ""
echo "🔄 Выполняем git pull..."
git pull origin catalog-parser

if [ $? -eq 0 ]; then
    echo "✅ Git pull выполнен успешно"
else
    echo "❌ Ошибка при выполнении git pull"
    exit 1
fi

echo ""
echo "🔄 Перезапускаем PM2 процесс..."
pm2 restart wolmar-parser

if [ $? -eq 0 ]; then
    echo "✅ PM2 процесс перезапущен успешно"
else
    echo "❌ Ошибка при перезапуске PM2"
    exit 1
fi

echo ""
echo "⏳ Ждем 3 секунды для запуска сервера..."
sleep 3

echo ""
echo "📊 Проверяем статус после обновления:"
pm2 status

echo ""
echo "🏥 Проверяем здоровье сервера..."
curl -s http://localhost:3001/api/health | jq . 2>/dev/null || echo "❌ Сервер не отвечает или jq не установлен"

echo ""
echo "✅ Обновление завершено!"
echo "🌐 Сервер доступен по адресу: http://46.173.19.68:3001"
echo "📊 Мониторинг: http://46.173.19.68:3001/monitor"
echo "⚙️ Админ панель: http://46.173.19.68:3001/admin"
