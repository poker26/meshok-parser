#!/bin/bash

echo "🚀 Быстрое развертывание каталога на сервере"
echo "============================================="

# Проверяем, что мы на правильной ветке
CURRENT_BRANCH=$(git branch --show-current)
echo "📋 Текущая ветка: $CURRENT_BRANCH"

if [ "$CURRENT_BRANCH" != "coins" ]; then
    echo "❌ Ошибка: Нужно быть на ветке 'coins'"
    echo "💡 Выполните: git checkout coins"
    exit 1
fi

echo "✅ Мы на правильной ветке: $CURRENT_BRANCH"

# Пушим изменения на GitHub
echo ""
echo "📤 Отправляем изменения на GitHub..."
git add .
git commit -m "Финальная версия каталога с данными о весе"
git push origin coins

echo ""
echo "✅ Изменения отправлены на GitHub"
echo ""
echo "📋 Команды для выполнения на сервере:"
echo "===================================="
echo ""
echo "1. Подключитесь к серверу:"
echo "   ssh root@46.173.19.68"
echo ""
echo "2. Выполните команды на сервере:"
echo "   cd /root/wolmar-parser"
echo "   git fetch origin"
echo "   git checkout coins"
echo "   git pull origin coins"
echo "   pm2 stop catalog 2>/dev/null"
echo "   pm2 start catalog-server.js --name catalog"
echo "   pm2 status"
echo ""
echo "3. Проверьте работу:"
echo "   - Основной сайт: http://46.173.19.68:3001"
echo "   - Каталог: http://46.173.19.68:3000"
echo ""
echo "⚠️  ВАЖНО: Основной сайт должен остаться на порту 3001!"
echo "⚠️  Каталог должен работать на порту 3000!"
echo ""
echo "🔧 Если что-то пойдет не так:"
echo "   pm2 stop catalog"
echo "   pm2 restart wolmar-parser"


