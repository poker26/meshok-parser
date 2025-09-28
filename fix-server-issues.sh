#!/bin/bash

# Скрипт для исправления проблем с сервером
# Восстанавливает работу основного сервера и каталога монет

echo "🔧 Исправление проблем с сервером..."
echo "===================================="

# Проверяем, что мы на сервере
if [ ! -f "/var/www/wolmar-parser/server.js" ]; then
    echo "❌ Ошибка: Скрипт должен запускаться на сервере в /var/www/wolmar-parser"
    exit 1
fi

cd /var/www/wolmar-parser

echo "🔄 ЭТАП 1: Остановка всех процессов PM2..."
pm2 stop all
pm2 delete all

echo ""
echo "🔄 ЭТАП 2: Переключение на основную ветку..."
git checkout catalog-parser --force
git pull origin catalog-parser

echo ""
echo "🔄 ЭТАП 3: Восстановление основного сервера..."

# Проверяем, что API endpoints каталога удалены из основного сервера
if grep -q "/api/auctions" server.js; then
    echo "⚠️ В основном сервере найдены endpoints каталога, удаляем..."
    node remove-catalog-endpoints.js
else
    echo "✅ Основной сервер очищен от endpoints каталога"
fi

# Запускаем основной сервер
pm2 start ecosystem.config.js

if [ $? -eq 0 ]; then
    echo "✅ Основной сервер запущен"
else
    echo "❌ Ошибка запуска основного сервера"
    exit 1
fi

echo ""
echo "🔄 ЭТАП 4: Настройка каталога монет..."

# Переключаемся на ветку каталога
git checkout web-interface

if [ $? -eq 0 ]; then
    echo "✅ Переключились на ветку web-interface"
else
    echo "❌ Ошибка переключения на ветку web-interface"
    exit 1
fi

# Создаем директорию для каталога
mkdir -p /var/www/catalog-interface
cd /var/www/catalog-interface

# Копируем файлы каталога
cp -r /var/www/wolmar-parser/public/ ./
cp /var/www/wolmar-parser/server.js ./
cp /var/www/wolmar-parser/package.json ./
cp /var/www/wolmar-parser/package-lock.json ./
cp /var/www/wolmar-parser/config.example.js ./

# Настраиваем каталог
cp config.example.js config.js

# Устанавливаем зависимости
npm install

# Запускаем каталог
pm2 start server.js --name "catalog-interface"

if [ $? -eq 0 ]; then
    echo "✅ Каталог монет запущен"
else
    echo "❌ Ошибка запуска каталога монет"
    exit 1
fi

echo ""
echo "🔄 ЭТАП 5: Настройка PM2..."
pm2 save
pm2 startup

echo ""
echo "🔍 ЭТАП 6: Финальная проверка..."

# Проверяем статус PM2
pm2 status

# Проверяем основной сервер
echo "🌐 Проверка основного сервера..."
curl -s http://localhost:3001/api/health > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Основной сервер работает на порту 3001"
else
    echo "❌ Основной сервер не отвечает"
fi

# Проверяем каталог
echo "🌐 Проверка каталога монет..."
curl -s http://localhost:3000/api/auctions > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Каталог монет работает на порту 3000"
else
    echo "❌ Каталог монет не отвечает"
fi

echo ""
echo "✅ ИСПРАВЛЕНИЕ ЗАВЕРШЕНО!"
echo "============================================="
echo "🌐 Основной сервер: http://46.173.19.68:3001"
echo "📚 Каталог монет: http://46.173.19.68:3000"
echo "📊 Мониторинг: pm2 status"
echo "📋 Логи: pm2 logs"
