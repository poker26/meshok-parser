#!/bin/bash

echo "🚀 Обновление основного сайта на сервере..."

# Переходим в директорию основного сайта
cd /root/wolmar-parser

# Останавливаем старый сервер
echo "⏹️ Останавливаем старый сервер..."
pm2 stop wolmar-parser 2>/dev/null || true
pm2 delete wolmar-parser 2>/dev/null || true

# Обновляем код
echo "📥 Обновляем код с GitHub..."
git fetch origin
git checkout coins
git pull origin coins

# Устанавливаем зависимости (если нужно)
echo "📦 Проверяем зависимости..."
npm install

# Очищаем старые логи и прогресс
echo "🧹 Очищаем старые файлы..."
rm -f catalog-parser-pid.json
rm -f catalog-progress.json
rm -f catalog-activity.log
rm -f catalog-errors.log

# Запускаем новый сервер
echo "🚀 Запускаем новый сервер..."
pm2 start server.js --name wolmar-parser

# Показываем статус
echo "📊 Статус серверов:"
pm2 status

echo "✅ Обновление основного сайта завершено!"
echo "🌐 Сайт доступен по адресу: http://46.173.19.68:3001"
echo "🔧 Админ-панель: http://46.173.19.68:3001/admin"






