#!/bin/bash

echo "🚨 СРОЧНОЕ ВОССТАНОВЛЕНИЕ ОСНОВНОГО САЙТА..."

# Останавливаем все процессы
echo "🛑 Остановка всех процессов..."
pm2 stop all
pm2 delete all

# Переключаемся на основную ветку
echo "🔄 Переключение на основную ветку..."
git checkout main
git pull origin main

# Устанавливаем зависимости
echo "📦 Установка зависимостей..."
npm install

# Запускаем основной сайт
echo "🚀 Запуск основного сайта..."
pm2 start server.js --name wolmar-parser
pm2 start admin-server.js --name admin-server

# Сохраняем конфигурацию
pm2 save

echo "✅ Основной сайт восстановлен!"
echo ""
echo "📊 Статус процессов:"
pm2 status

echo ""
echo "🌐 Основной сайт доступен на:"
echo "   http://server:3001"
echo "   http://server:3001/admin"
