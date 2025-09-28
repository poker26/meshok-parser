#!/bin/bash

# Быстрое исправление проблемы с Git на сервере
# Простое решение для ошибки "Please commit your changes or stash them"

echo "⚡ Быстрое исправление Git на сервере..."
echo "====================================="

cd /var/www/wolmar-parser

echo "🔄 Принудительное переключение с игнорированием изменений..."
git checkout catalog-parser --force

echo "📥 Получение изменений..."
git pull origin catalog-parser

echo "✅ Готово!"
