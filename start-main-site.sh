#!/bin/bash

# Запуск основного сайта после тестирования каталога
# Запускает основной сервер на порту 3001

echo "🚀 ЗАПУСК ОСНОВНОГО САЙТА..."
echo "==========================="

# Проверяем, что мы на сервере
if [ ! -f "/var/www/wolmar-parser/server.js" ]; then
    echo "❌ Ошибка: Скрипт должен запускаться на сервере в /var/www/wolmar-parser"
    exit 1
fi

cd /var/www/wolmar-parser

echo "📊 ЭТАП 1: Проверка текущего статуса..."
echo "===================================="

echo "🔍 Статус PM2:"
pm2 status

echo ""
echo "🔍 Процессы на портах:"
netstat -tlnp | grep -E ":(3000|3001|3002)"

echo ""
echo "📊 ЭТАП 2: Подготовка основного сервера..."
echo "======================================"

echo "🔄 Переключение на основную ветку..."
git checkout catalog-parser --force
git pull origin catalog-parser

echo ""
echo "📊 ЭТАП 3: Запуск основного сервера..."
echo "=================================="

echo "🚀 Запуск основного сервера на порту 3001..."
pm2 start ecosystem.config.js

if [ $? -eq 0 ]; then
    echo "✅ Основной сервер запущен через PM2"
else
    echo "❌ Ошибка запуска основного сервера"
    exit 1
fi

echo ""
echo "⏳ ЭТАП 4: Ожидание запуска основного сервера..."
sleep 5

echo ""
echo "📊 ЭТАП 5: Проверка работы системы..."
echo "================================="

echo "🔍 Статус PM2:"
pm2 status

echo ""
echo "🔍 Процессы на портах:"
netstat -tlnp | grep -E ":(3000|3001|3002)"

echo ""
echo "🌐 Тестирование основного сервера (порт 3001):"
curl -s http://localhost:3001/api/health > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Основной сервер работает на порту 3001"
    echo "🌐 Доступен: http://46.173.19.68:3001"
else
    echo "❌ Основной сервер не работает"
    echo "📋 Логи основного сервера:"
    pm2 logs wolmar-parser --lines 10
fi

echo ""
echo "🌐 Тестирование каталога (порт 3000):"
curl -s http://localhost:3000/api/test > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Каталог монет работает на порту 3000"
    echo "🌐 Доступен: http://46.173.19.68:3000"
else
    echo "❌ Каталог монет не работает"
    echo "📋 Логи каталога:"
    pm2 logs catalog-interface --lines 10
fi

echo ""
echo "🔍 Сравнение содержимого портов:"
echo "📋 Первые 3 строки порта 3001 (основной сервер):"
curl -s http://localhost:3001/ | head -3

echo ""
echo "📋 Первые 3 строки порта 3000 (каталог):"
curl -s http://localhost:3000/ | head -3

echo ""
echo "✅ ОСНОВНОЙ САЙТ ЗАПУЩЕН!"
echo "============================================="
echo "🌐 Основной сервер: http://46.173.19.68:3001"
echo "📚 Каталог монет: http://46.173.19.68:3000"
echo "📊 Мониторинг: pm2 status"
echo "📋 Логи основного сервера: pm2 logs wolmar-parser"
echo "📋 Логи каталога: pm2 logs catalog-interface"
