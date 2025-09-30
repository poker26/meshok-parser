#!/bin/bash

# Диагностический скрипт для проверки PM2
# Проверяет доступность PM2 и его настройки

echo "🔍 Диагностика PM2..."
echo "===================="

echo "📊 Проверяем установку PM2..."
if command -v pm2 >/dev/null 2>&1; then
    echo "✅ PM2 установлен"
    pm2 --version
else
    echo "❌ PM2 не установлен"
    echo "💡 Установите PM2: npm install -g pm2"
    exit 1
fi

echo ""
echo "📊 Проверяем статус PM2..."
pm2 status

echo ""
echo "📊 Проверяем процессы PM2..."
pm2 list

echo ""
echo "📊 Проверяем логи PM2..."
pm2 logs --lines 5 --nostream

echo ""
echo "🧪 Тестируем запуск простого процесса через PM2..."
echo "Команда: pm2 start 'echo test' --name 'test-process'"

# Тестируем запуск простого процесса
pm2 start 'echo test' --name 'test-process'

if [ $? -eq 0 ]; then
    echo "✅ PM2 команда выполнилась успешно"
    
    echo ""
    echo "📊 Статус после теста:"
    pm2 status
    
    echo ""
    echo "🧹 Очищаем тестовый процесс..."
    pm2 stop test-process
    pm2 delete test-process
    
    echo "✅ PM2 работает нормально"
else
    echo "❌ Ошибка выполнения PM2 команды"
    echo "💡 Проверьте права доступа и конфигурацию PM2"
fi

echo ""
echo "📋 Рекомендации:"
echo "================"
echo "1. Убедитесь, что PM2 установлен глобально: npm install -g pm2"
echo "2. Проверьте права доступа: sudo chown -R $USER:$USER ~/.pm2"
echo "3. Перезапустите PM2: pm2 kill && pm2 resurrect"
echo "4. Проверьте конфигурацию: pm2 startup"
