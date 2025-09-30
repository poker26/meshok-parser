#!/bin/bash

# Скрипт для диагностики проблем с сервером
# Проверяет работу основного сервера и каталога монет

echo "🔍 Диагностика проблем с сервером..."
echo "===================================="

# Проверяем, что мы на сервере
if [ ! -f "/var/www/wolmar-parser/server.js" ]; then
    echo "❌ Ошибка: Скрипт должен запускаться на сервере в /var/www/wolmar-parser"
    exit 1
fi

cd /var/www/wolmar-parser

echo "📊 ЭТАП 1: Проверка статуса PM2..."
pm2 status

echo ""
echo "🔍 ЭТАП 2: Проверка процессов на портах..."
netstat -tlnp | grep -E ":(3000|3001)"

echo ""
echo "🌐 ЭТАП 3: Проверка основного сервера (порт 3001)..."
curl -s http://localhost:3001/api/health
if [ $? -eq 0 ]; then
    echo "✅ Основной сервер отвечает"
else
    echo "❌ Основной сервер не отвечает"
fi

echo ""
echo "🌐 ЭТАП 4: Проверка API аукционов..."
curl -s http://localhost:3001/api/auctions
if [ $? -eq 0 ]; then
    echo "✅ API аукционов работает"
else
    echo "❌ API аукционов не работает"
fi

echo ""
echo "🌐 ЭТАП 5: Проверка каталога монет (порт 3000)..."
curl -s http://localhost:3000/api/auctions
if [ $? -eq 0 ]; then
    echo "✅ Каталог монет работает"
else
    echo "❌ Каталог монет не работает"
fi

echo ""
echo "📋 ЭТАП 6: Проверка логов основного сервера..."
pm2 logs wolmar-parser --lines 10

echo ""
echo "📋 ЭТАП 7: Проверка логов каталога..."
pm2 logs catalog-interface --lines 10

echo ""
echo "🔍 ЭТАП 8: Проверка файлов сервера..."
ls -la /var/www/wolmar-parser/server.js
ls -la /var/www/catalog-interface/server.js

echo ""
echo "✅ Диагностика завершена!"
