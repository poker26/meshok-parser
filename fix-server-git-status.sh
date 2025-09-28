#!/bin/bash

# Скрипт для исправления проблем с Git на сервере
# Решает проблему "Please commit your changes or stash them before you switch branches"

echo "🔧 Исправление проблем с Git на сервере..."
echo "=========================================="

# Проверяем, что мы на сервере
if [ ! -f "/var/www/wolmar-parser/server.js" ]; then
    echo "❌ Ошибка: Скрипт должен запускаться на сервере в /var/www/wolmar-parser"
    exit 1
fi

cd /var/www/wolmar-parser

echo "📊 Текущий статус Git:"
git status

echo ""
echo "🔍 Проверяем незакоммиченные изменения..."

# Проверяем, есть ли незакоммиченные изменения
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️ Найдены незакоммиченные изменения:"
    git status --porcelain
    
    echo ""
    echo "🔄 Создаем stash для сохранения изменений..."
    git stash push -m "Автоматическое сохранение изменений $(date)"
    
    if [ $? -eq 0 ]; then
        echo "✅ Изменения сохранены в stash"
    else
        echo "❌ Ошибка создания stash"
        exit 1
    fi
else
    echo "✅ Нет незакоммиченных изменений"
fi

echo ""
echo "🔄 Принудительное переключение на ветку catalog-parser..."
git checkout catalog-parser --force

if [ $? -eq 0 ]; then
    echo "✅ Успешно переключились на ветку catalog-parser"
else
    echo "❌ Ошибка переключения на ветку catalog-parser"
    exit 1
fi

echo ""
echo "📥 Получаем последние изменения..."
git pull origin catalog-parser

if [ $? -eq 0 ]; then
    echo "✅ Изменения получены с GitHub"
else
    echo "❌ Ошибка получения изменений"
    exit 1
fi

echo ""
echo "🔍 Проверяем финальный статус..."
git status

echo ""
echo "📋 Список stash (сохраненные изменения):"
git stash list

echo ""
echo "✅ Проблема с Git исправлена!"
echo "💡 Если нужно восстановить изменения: git stash pop"
