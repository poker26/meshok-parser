#!/bin/bash

# Полный скрипт развертывания системы на сервере
# Учитывает все проблемы с Git и развертывает обе части системы

echo "🚀 Полное развертывание системы на сервере..."
echo "============================================="

# Проверяем, что мы на сервере
if [ ! -f "/var/www/wolmar-parser/server.js" ]; then
    echo "❌ Ошибка: Скрипт должен запускаться на сервере в /var/www/wolmar-parser"
    exit 1
fi

cd /var/www/wolmar-parser

echo "📊 Текущий статус:"
git status
git branch --show-current

echo ""
echo "🧹 ЭТАП 1: Очистка неотслеживаемых файлов..."

# Создаем резервную копию важных файлов
backup_dir="backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

# Сохраняем важные файлы
if [ -f "server.js.backup" ]; then
    cp server.js.backup "$backup_dir/"
    echo "✅ Сохранен server.js.backup"
fi

if [ -f "schedule.json" ]; then
    cp schedule.json "$backup_dir/"
    echo "✅ Сохранен schedule.json"
fi

if [ -f "predictions_progress_968.json" ]; then
    cp predictions_progress_968.json "$backup_dir/"
    echo "✅ Сохранен predictions_progress_968.json"
fi

# Удаляем неотслеживаемые файлы
git clean -fd

echo ""
echo "🔄 ЭТАП 2: Переключение на основную ветку..."
git checkout catalog-parser --force

if [ $? -eq 0 ]; then
    echo "✅ Переключились на ветку catalog-parser"
else
    echo "❌ Ошибка переключения на ветку catalog-parser"
    exit 1
fi

echo ""
echo "📥 ЭТАП 3: Получение последних изменений..."
git pull origin catalog-parser

if [ $? -eq 0 ]; then
    echo "✅ Изменения получены с GitHub"
else
    echo "❌ Ошибка получения изменений"
    exit 1
fi

echo ""
echo "📦 ЭТАП 4: Установка зависимостей основного сервера..."
npm install

if [ $? -eq 0 ]; then
    echo "✅ Зависимости установлены"
else
    echo "❌ Ошибка установки зависимостей"
    exit 1
fi

echo ""
echo "🔄 ЭТАП 5: Настройка PM2 для основного сервера..."

# Остановить существующие процессы
pm2 stop all 2>/dev/null || true

# Запустить основной сервер
pm2 start ecosystem.config.js

if [ $? -eq 0 ]; then
    echo "✅ Основной сервер запущен через PM2"
else
    echo "❌ Ошибка запуска основного сервера"
    exit 1
fi

echo ""
echo "🌐 ЭТАП 6: Развертывание каталога монет..."

# Переключиться на ветку каталога
git checkout web-interface

if [ $? -eq 0 ]; then
    echo "✅ Переключились на ветку web-interface"
else
    echo "❌ Ошибка переключения на ветку web-interface"
    exit 1
fi

# Создать директорию для каталога
mkdir -p /var/www/catalog-interface
cd /var/www/catalog-interface

# Копировать файлы каталога
cp -r /var/www/wolmar-parser/public/ ./
cp /var/www/wolmar-parser/server.js ./
cp /var/www/wolmar-parser/package.json ./
cp /var/www/wolmar-parser/package-lock.json ./
cp /var/www/wolmar-parser/config.example.js ./

echo "✅ Файлы каталога скопированы"

# Настроить каталог
cp config.example.js config.js
echo "✅ Конфигурация каталога создана"

# Установить зависимости каталога
npm install

if [ $? -eq 0 ]; then
    echo "✅ Зависимости каталога установлены"
else
    echo "❌ Ошибка установки зависимостей каталога"
    exit 1
fi

# Запустить каталог через PM2
pm2 start server.js --name "catalog-interface"

if [ $? -eq 0 ]; then
    echo "✅ Каталог запущен через PM2"
else
    echo "❌ Ошибка запуска каталога"
    exit 1
fi

echo ""
echo "🔧 ЭТАП 7: Настройка мониторинга..."

# Настроить автозапуск PM2
pm2 save
pm2 startup

# Настроить logrotate
pm2 install pm2-logrotate 2>/dev/null || true

echo ""
echo "📊 ЭТАП 8: Финальная проверка..."

# Проверить статус PM2
pm2 status

# Проверить работу основного сервера
echo "🔍 Проверка основного сервера..."
curl -s http://localhost:3001/api/health > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Основной сервер работает"
else
    echo "❌ Основной сервер не отвечает"
fi

# Проверить работу каталога
echo "🔍 Проверка каталога монет..."
curl -s http://localhost:3000/api/auctions > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Каталог монет работает"
else
    echo "❌ Каталог монет не отвечает"
fi

echo ""
echo "✅ РАЗВЕРТЫВАНИЕ ЗАВЕРШЕНО!"
echo "============================================="
echo "🌐 Основной сервер: http://46.173.19.68:3001"
echo "📚 Каталог монет: http://46.173.19.68:3000"
echo "💾 Резервные копии: $backup_dir/"
echo "📊 Мониторинг: pm2 status"
echo "📋 Логи: pm2 logs"
