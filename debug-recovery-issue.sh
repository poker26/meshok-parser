#!/bin/bash

# Диагностический скрипт для отладки проблемы с восстановлением парсеров
# Проверяет файлы прогресса и логи

echo "🔍 Диагностика проблемы с восстановлением парсеров..."
echo "=================================================="

# Проверяем, что мы в правильной директории
if [ ! -f "server.js" ]; then
    echo "❌ Ошибка: Запустите из директории wolmar-parser"
    exit 1
fi

echo "📁 Текущая директория: $(pwd)"
echo ""

# Проверяем наличие файлов прогресса
echo "📊 Проверяем файлы прогресса..."
echo "================================"

# Ищем все файлы прогресса
echo "🔍 Ищем файлы прогресса:"
find . -name "*progress*.json" -type f 2>/dev/null | head -10

echo ""
echo "📋 Содержимое директории:"
ls -la *.json 2>/dev/null || echo "❌ JSON файлы не найдены"

echo ""
echo "📊 Проверяем логи PM2..."
echo "========================"

# Проверяем логи PM2
echo "🔍 Последние логи PM2:"
pm2 logs wolmar-parser --lines 20 --nostream 2>/dev/null || echo "❌ Не удалось получить логи PM2"

echo ""
echo "📊 Проверяем статус PM2..."
echo "=========================="
pm2 status

echo ""
echo "🔍 Проверяем логи системы..."
echo "============================="

# Проверяем системные логи
echo "📋 Последние записи в логах:"
tail -20 /var/log/wolmar-auto-restart.log 2>/dev/null || echo "❌ Логи мониторинга не найдены"

echo ""
echo "🧪 Создаем тестовые файлы прогресса..."
echo "====================================="

# Создаем тестовые файлы прогресса
cat > test_parser_progress_2133.json << EOF
{
    "auctionNumber": "2133",
    "currentLot": 150,
    "progress": 75.5,
    "totalLots": 200,
    "lastUpdate": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)"
}
EOF

cat > test_mass_update_progress_968.json << EOF
{
    "auctionNumber": "968",
    "updateProgress": {
        "currentLot": 200,
        "progress": 80.0,
        "totalLots": 250
    },
    "lastUpdate": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)"
}
EOF

echo "✅ Тестовые файлы созданы"

echo ""
echo "🔍 Запускаем анализ с тестовыми файлами..."
echo "==========================================="

# Запускаем анализ
node analyze-crash-recovery.js

echo ""
echo "📄 Проверяем отчет..."
if [ -f "crash-recovery-report.json" ]; then
    echo "✅ Отчет создан:"
    cat crash-recovery-report.json | jq . 2>/dev/null || cat crash-recovery-report.json
else
    echo "❌ Отчет не создан"
fi

echo ""
echo "🧹 Очищаем тестовые файлы..."
rm -f test_*.json crash-recovery-report.json

echo ""
echo "📋 Рекомендации:"
echo "================"
echo "1. Проверьте, что основной парсер создает файлы прогресса"
echo "2. Убедитесь, что файлы прогресса сохраняются в правильной директории"
echo "3. Проверьте права доступа к файлам прогресса"
echo "4. Убедитесь, что парсер использует правильные имена файлов прогресса"
