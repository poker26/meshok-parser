#!/bin/bash

echo "🚀 Обновление каталога на сервере..."

# Переходим в директорию каталога
cd /root/wolmar-parser

# Останавливаем старый сервер каталога
echo "⏹️ Останавливаем старый сервер каталога..."
pm2 stop catalog 2>/dev/null || true
pm2 delete catalog 2>/dev/null || true

# Обновляем код
echo "📥 Обновляем код с GitHub..."
git fetch origin
git checkout coins
git pull origin coins

# Устанавливаем зависимости (если нужно)
echo "📦 Проверяем зависимости..."
npm install

# Запускаем новый сервер каталога
echo "🚀 Запускаем новый сервер каталога..."
pm2 start catalog-server.js --name catalog

# Показываем статус
echo "📊 Статус серверов:"
pm2 status

echo "✅ Обновление каталога завершено!"
echo "🌐 Каталог доступен по адресу: http://46.173.19.68:3000"




