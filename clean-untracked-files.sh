#!/bin/bash

# Скрипт для очистки неотслеживаемых файлов на сервере
# Удаляет временные файлы, которые мешают переключению веток

echo "🧹 Очистка неотслеживаемых файлов на сервере..."
echo "=============================================="

# Проверяем, что мы на сервере
if [ ! -f "/var/www/wolmar-parser/server.js" ]; then
    echo "❌ Ошибка: Скрипт должен запускаться на сервере в /var/www/wolmar-parser"
    exit 1
fi

cd /var/www/wolmar-parser

echo "📊 Текущий статус Git:"
git status

echo ""
echo "🔍 Найденные неотслеживаемые файлы:"
git status --porcelain | grep "^??"

echo ""
echo "🗑️ Удаляем неотслеживаемые файлы..."

# Создаем резервную копию важных файлов
echo "💾 Создаем резервную копию важных файлов..."
mkdir -p backup-untracked-$(date +%Y%m%d_%H%M%S)

# Сохраняем важные файлы
if [ -f "server.js.backup" ]; then
    cp server.js.backup backup-untracked-$(date +%Y%m%d_%H%M%S)/
    echo "✅ Сохранен server.js.backup"
fi

if [ -f "schedule.json" ]; then
    cp schedule.json backup-untracked-$(date +%Y%m%d_%H%M%S)/
    echo "✅ Сохранен schedule.json"
fi

if [ -f "predictions_progress_968.json" ]; then
    cp predictions_progress_968.json backup-untracked-$(date +%Y%m%d_%H%M%S)/
    echo "✅ Сохранен predictions_progress_968.json"
fi

# Удаляем неотслеживаемые файлы
echo ""
echo "🧹 Удаляем неотслеживаемые файлы..."
git clean -fd

if [ $? -eq 0 ]; then
    echo "✅ Неотслеживаемые файлы удалены"
else
    echo "❌ Ошибка удаления файлов"
    exit 1
fi

echo ""
echo "🔄 Принудительное переключение на ветку catalog-parser..."
git checkout catalog-parser --force

if [ $? -eq 0 ]; then
    echo "✅ Переключились на ветку catalog-parser"
else
    echo "❌ Ошибка переключения на ветку catalog-parser"
    exit 1
fi

echo ""
echo "📥 Получение последних изменений..."
git pull origin catalog-parser

if [ $? -eq 0 ]; then
    echo "✅ Изменения получены с GitHub"
else
    echo "❌ Ошибка получения изменений"
    exit 1
fi

echo ""
echo "🔍 Финальная проверка..."
git status

echo ""
echo "✅ Очистка завершена!"
echo "💡 Важные файлы сохранены в backup-untracked-*/"
echo "🌐 Теперь можно развертывать систему"
