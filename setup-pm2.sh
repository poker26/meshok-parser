#!/bin/bash

# Скрипт для настройки PM2 на сервере
# Запуск: bash setup-pm2.sh

echo "🚀 Настройка PM2 для wolmar-parser..."

# Проверка, что мы в правильной директории
if [ ! -f "server.js" ]; then
    echo "❌ Ошибка: server.js не найден. Запустите скрипт из директории проекта."
    exit 1
fi

# Создание директории для логов
echo "📁 Создание директории для логов..."
mkdir -p logs
chmod 755 logs

# Установка PM2 (если не установлен)
echo "📦 Проверка установки PM2..."
if ! command -v pm2 &> /dev/null; then
    echo "📦 Установка PM2..."
    npm install -g pm2
else
    echo "✅ PM2 уже установлен"
fi

# Остановка текущего сервера
echo "🛑 Остановка текущего сервера..."
pkill -f "node server.js" || true
sleep 2

# Запуск через PM2
echo "🚀 Запуск сервера через PM2..."
pm2 start ecosystem.config.js

# Проверка статуса
echo "📊 Проверка статуса..."
pm2 status

# Настройка автозапуска
echo "⚙️ Настройка автозапуска..."
pm2 save
pm2 startup

echo "✅ Настройка PM2 завершена!"
echo ""
echo "📋 Полезные команды:"
echo "  pm2 status          - статус процессов"
echo "  pm2 logs            - просмотр логов"
echo "  pm2 monit           - мониторинг"
echo "  pm2 restart wolmar-parser - перезапуск"
echo "  pm2 stop wolmar-parser    - остановка"
echo ""
echo "🌐 Сервер должен быть доступен по адресу: http://46.173.19.68:3001"
