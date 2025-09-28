#!/bin/bash

# Скрипт для проверки содержимого портов
# Проверяет что именно открывается на портах 3000 и 3001

echo "🔍 Проверка содержимого портов..."
echo "================================="

echo "📊 ЭТАП 1: Проверка статуса PM2..."
pm2 status

echo ""
echo "📊 ЭТАП 2: Проверка процессов на портах..."
netstat -tlnp | grep -E ":(3000|3001)"

echo ""
echo "🌐 ЭТАП 3: Проверка содержимого порта 3001 (основной сервер)..."
echo "📋 Заголовок страницы:"
curl -s http://localhost:3001/ | grep -o '<title>.*</title>' || echo "Не удалось получить заголовок"

echo "📋 API health:"
curl -s http://localhost:3001/api/health | head -1

echo ""
echo "🌐 ЭТАП 4: Проверка содержимого порта 3000 (каталог)..."
echo "📋 Заголовок страницы:"
curl -s http://localhost:3000/ | grep -o '<title>.*</title>' || echo "Не удалось получить заголовок"

echo "📋 API каталога:"
curl -s http://localhost:3000/api/auctions | head -1

echo ""
echo "📊 ЭТАП 5: Сравнение содержимого..."
echo "📋 Первые 5 строк порта 3001:"
curl -s http://localhost:3001/ | head -5

echo ""
echo "📋 Первые 5 строк порта 3000:"
curl -s http://localhost:3000/ | head -5

echo ""
echo "✅ ПРОВЕРКА ЗАВЕРШЕНА!"
echo "💡 Если оба порта показывают одинаковое содержимое, запустите ./fix-catalog-wrong-page.sh"
