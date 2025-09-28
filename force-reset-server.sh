#!/bin/bash

# Скрипт для принудительного сброса Git на сервере
# Используется когда обычные методы не работают

echo "🔄 Принудительный сброс Git на сервере..."
echo "======================================="

# Проверяем, что мы на сервере
if [ ! -f "/var/www/wolmar-parser/server.js" ]; then
    echo "❌ Ошибка: Скрипт должен запускаться на сервере в /var/www/wolmar-parser"
    exit 1
fi

cd /var/www/wolmar-parser

echo "📊 Текущий статус:"
git status

echo ""
echo "🔄 Принудительный сброс всех изменений..."
git reset --hard HEAD

if [ $? -eq 0 ]; then
    echo "✅ Сброс выполнен"
else
    echo "❌ Ошибка сброса"
    exit 1
fi

echo ""
echo "🧹 Очистка неотслеживаемых файлов..."
git clean -fd

if [ $? -eq 0 ]; then
    echo "✅ Очистка выполнена"
else
    echo "❌ Ошибка очистки"
    exit 1
fi

echo ""
echo "🔄 Принудительное переключение на ветку catalog-parser..."
git checkout catalog-parser --force

if [ $? -eq 0 ]; then
    echo "✅ Переключение выполнено"
else
    echo "❌ Ошибка переключения"
    exit 1
fi

echo ""
echo "📥 Получение последних изменений..."
git pull origin catalog-parser

if [ $? -eq 0 ]; then
    echo "✅ Изменения получены"
else
    echo "❌ Ошибка получения изменений"
    exit 1
fi

echo ""
echo "🔍 Финальная проверка..."
git status

echo ""
echo "✅ Принудительный сброс завершен!"
echo "💡 Все локальные изменения удалены"
