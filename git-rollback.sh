#!/bin/bash

# Wolmar Parser - Git Rollback Script
# Автор: Wolmar Team
# Версия: 2.0.0

set -e

echo "⏪ Откат Wolmar Parser к предыдущей версии..."

# Проверяем, что мы в Git репозитории
if [ ! -d .git ]; then
    echo "❌ Это не Git репозиторий!"
    exit 1
fi

# Показываем историю коммитов
echo "📋 История коммитов:"
git log --oneline -10

# Спрашиваем, к какому коммиту откатиться
echo ""
echo "🔍 Выберите коммит для отката:"
echo "1. Предыдущий коммит (HEAD~1)"
echo "2. Два коммита назад (HEAD~2)"
echo "3. Три коммита назад (HEAD~3)"
echo "4. Ввести хеш коммита вручную"
echo "5. Отмена"

read -p "Введите номер (1-5): " choice

case $choice in
    1)
        COMMIT="HEAD~1"
        ;;
    2)
        COMMIT="HEAD~2"
        ;;
    3)
        COMMIT="HEAD~3"
        ;;
    4)
        read -p "Введите хеш коммита: " COMMIT
        ;;
    5)
        echo "❌ Откат отменен"
        exit 0
        ;;
    *)
        echo "❌ Неверный выбор"
        exit 1
        ;;
esac

# Создаем бэкап текущего состояния
echo "💾 Создание бэкапа текущего состояния..."
BACKUP_DIR="backup/rollback-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Копируем важные файлы
cp .env "$BACKUP_DIR/" 2>/dev/null || true
cp ecosystem.config.js "$BACKUP_DIR/" 2>/dev/null || true

echo "📦 Бэкап создан в: $BACKUP_DIR"

# Останавливаем процессы
echo "🛑 Остановка процессов..."
pm2 stop all

# Выполняем откат
echo "⏪ Откат к коммиту: $COMMIT"
git reset --hard "$COMMIT"

# Устанавливаем зависимости
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

echo "✅ Откат завершен успешно!"
echo "🌐 Основной сервер: http://localhost:3001"
echo "📚 Каталог: http://localhost:3000"
echo ""
echo "📋 Полезные команды:"
echo "  pm2 status          - статус приложений"
echo "  pm2 logs            - просмотр логов"
echo "  pm2 restart all     - перезапуск всех приложений"
echo "  pm2 monit           - мониторинг в реальном времени"
