#!/bin/bash

echo "🔧 Исправление переключения веток на сервере..."

# Сохраняем локальные изменения
echo "💾 Сохранение локальных изменений..."
git stash push -m "Локальные изменения перед переключением на main-website"

# Переключаемся на ветку main-website
echo "🔄 Переключение на ветку main-website..."
git checkout main-website

# Получаем последние изменения
echo "📥 Получение последних изменений..."
git pull origin main-website

# Останавливаем все процессы
echo "🛑 Остановка всех процессов..."
pm2 stop all
pm2 delete all

# Запускаем основной сайт
echo "🚀 Запуск основного сайта..."
pm2 start server.js --name wolmar-parser
pm2 start admin-server.js --name admin-server

# Сохраняем конфигурацию PM2
pm2 save

echo "✅ Основной сайт восстановлен!"
echo ""
echo "📊 Статус процессов:"
pm2 status

echo ""
echo "🌐 Основной сайт доступен на:"
echo "   http://server:3001"
echo "   http://server:3001/admin"


