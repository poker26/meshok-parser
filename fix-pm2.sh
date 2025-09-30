#!/bin/bash

# Скрипт для исправления проблем с PM2
# Устанавливает и настраивает PM2 для работы с парсерами

echo "🔧 Исправление PM2..."
echo "===================="

# Проверяем, установлен ли PM2
if ! command -v pm2 >/dev/null 2>&1; then
    echo "📦 Устанавливаем PM2..."
    npm install -g pm2
    
    if [ $? -eq 0 ]; then
        echo "✅ PM2 установлен успешно"
    else
        echo "❌ Ошибка установки PM2"
        echo "💡 Попробуйте: sudo npm install -g pm2"
        exit 1
    fi
else
    echo "✅ PM2 уже установлен"
fi

echo ""
echo "🔧 Настраиваем PM2..."

# Останавливаем все процессы PM2
pm2 kill 2>/dev/null || true

# Настраиваем автозапуск
pm2 startup 2>/dev/null || true

# Создаем базовую конфигурацию PM2
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'wolmar-parser',
    script: 'server.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production'
    }
  }]
};
EOF

echo "✅ Конфигурация PM2 создана"

echo ""
echo "🚀 Запускаем основной сервер через PM2..."
pm2 start ecosystem.config.js

if [ $? -eq 0 ]; then
    echo "✅ Сервер запущен через PM2"
    
    echo ""
    echo "💾 Сохраняем конфигурацию PM2..."
    pm2 save
    
    echo ""
    echo "📊 Статус PM2:"
    pm2 status
    
    echo ""
    echo "✅ PM2 настроен и работает!"
    echo "💡 Теперь восстановление парсеров будет использовать PM2"
else
    echo "❌ Ошибка запуска сервера через PM2"
    exit 1
fi
