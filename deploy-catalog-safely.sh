#!/bin/bash

echo "🚀 Безопасное развертывание каталога на сервере"
echo "================================================"

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
git commit -m "Обновленный каталог с данными о весе и изображениями"
git push origin coins

echo ""
echo "✅ Изменения отправлены на GitHub"
echo ""
echo "📋 Инструкции для развертывания на сервере:"
echo "============================================"
echo ""
echo "1. Подключитесь к серверу:"
echo "   ssh root@46.173.19.68"
echo ""
echo "2. Перейдите в директорию проекта:"
echo "   cd /root/wolmar-parser"
echo ""
echo "3. Переключитесь на ветку coins:"
echo "   git fetch origin"
echo "   git checkout coins"
echo "   git pull origin coins"
echo ""
echo "4. Остановите основной сайт (если нужно):"
echo "   pm2 stop wolmar-parser"
echo ""
echo "5. Запустите каталог на порту 3000:"
echo "   node catalog-server.js"
echo ""
echo "6. Или запустите через PM2:"
echo "   pm2 start catalog-server.js --name catalog -- --port 3000"
echo ""
echo "7. Проверьте работу:"
echo "   - Основной сайт: http://46.173.19.68:3001"
echo "   - Каталог: http://46.173.19.68:3000"
echo ""
echo "⚠️  ВАЖНО: Основной сайт должен остаться на порту 3001!"
echo "⚠️  Каталог должен работать на порту 3000!"
echo ""
echo "🔧 Если что-то пойдет не так, восстановите основной сайт:"
echo "   pm2 restart wolmar-parser"






