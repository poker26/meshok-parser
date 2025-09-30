#!/bin/bash

# Wolmar Parser - Git Update Script
# Автор: Wolmar Team
# Версия: 2.0.0

set -e

echo "🔄 Обновление Wolmar Parser через Git..."

# Проверяем, что мы в Git репозитории
if [ ! -d .git ]; then
    echo "❌ Это не Git репозиторий!"
    exit 1
fi

# Создаем бэкап текущего состояния
echo "💾 Создание бэкапа..."
BACKUP_DIR="backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Копируем важные файлы
cp .env "$BACKUP_DIR/" 2>/dev/null || true
cp ecosystem.config.js "$BACKUP_DIR/" 2>/dev/null || true

echo "📦 Бэкап создан в: $BACKUP_DIR"

# Останавливаем процессы
echo "🛑 Остановка процессов..."
pm2 stop all

# Получаем обновления
echo "📥 Получение обновлений..."
git fetch origin

# Показываем изменения
echo "📋 Изменения:"
git log HEAD..origin/main --oneline

# Применяем обновления
echo "🔄 Применение обновлений..."
git pull origin main

# Устанавливаем новые зависимости
echo "📦 Установка зависимостей..."
npm install --production

# Запускаем процессы
echo "🚀 Запуск процессов..."
pm2 start ecosystem.config.js

# Показываем статус
echo "📊 Статус приложений:"
pm2 status

# Показываем последние логи
echo "📋 Последние логи:"
pm2 logs --lines 10

echo "✅ Обновление завершено успешно!"
echo "🌐 Основной сервер: http://localhost:3001"
echo "📚 Каталог: http://localhost:3000"
echo ""
echo "📋 Полезные команды:"
echo "  pm2 status          - статус приложений"
echo "  pm2 logs            - просмотр логов"
echo "  pm2 restart all     - перезапуск всех приложений"
echo "  pm2 monit           - мониторинг в реальном времени"
