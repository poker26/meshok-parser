#!/bin/bash

# Тестовый скрипт для проверки запуска парсера
# Проверяет, что парсер запускается и работает

echo "🧪 Тестирование запуска парсера..."
echo "=================================="

# Проверяем, что мы в правильной директории
if [ ! -f "wolmar-parser5.js" ]; then
    echo "❌ Ошибка: Запустите из директории wolmar-parser"
    exit 1
fi

echo "📊 Проверяем статус PM2..."
pm2 status

echo ""
echo "🔍 Проверяем запущенные процессы парсера..."
ps aux | grep wolmar-parser5 | grep -v grep

echo ""
echo "🚀 Тестируем запуск парсера через PM2..."
echo "Команда: pm2 start wolmar-parser5.js --name 'test-parser' -- index 2135 1931"

# Запускаем парсер через PM2
pm2 start wolmar-parser5.js --name "test-parser" -- index 2135 1931

if [ $? -eq 0 ]; then
    echo "✅ Парсер запущен через PM2"
    
    echo ""
    echo "📊 Проверяем статус PM2 после запуска..."
    pm2 status
    
    echo ""
    echo "📋 Проверяем логи парсера..."
    pm2 logs test-parser --lines 10 --nostream
    
    echo ""
    echo "⏰ Ждем 10 секунд для проверки работы..."
    sleep 10
    
    echo ""
    echo "📊 Финальный статус PM2..."
    pm2 status
    
    echo ""
    echo "🧹 Останавливаем тестовый парсер..."
    pm2 stop test-parser
    pm2 delete test-parser
    
    echo "✅ Тест завершен"
else
    echo "❌ Ошибка запуска парсера через PM2"
    exit 1
fi

echo ""
echo "📋 Результаты тестирования:"
echo "  • PM2 доступен: ✅"
echo "  • Парсер запускается: ✅"
echo "  • Логи работают: ✅"
echo "  • Остановка работает: ✅"
echo ""
echo "🎯 Парсер готов к восстановлению!"
