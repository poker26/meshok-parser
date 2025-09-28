#!/bin/bash

# Диагностика проблемы в строке 48 server.js каталога
# Выясняет что именно вызывает MODULE_NOT_FOUND

echo "🔍 ДИАГНОСТИКА ПРОБЛЕМЫ В СТРОКЕ 48..."
echo "===================================="

cd /var/www/catalog-interface

echo "📊 ЭТАП 1: Проверка файла server.js..."
echo "==================================="

if [ -f "server.js" ]; then
    echo "✅ server.js найден"
    echo "📋 Размер файла: $(wc -l < server.js) строк"
    echo "📋 Строка 48:"
    sed -n '48p' server.js
    echo ""
    echo "📋 Строки 45-50:"
    sed -n '45,50p' server.js
else
    echo "❌ server.js не найден"
    exit 1
fi

echo ""
echo "📊 ЭТАП 2: Проверка всех require() в server.js..."
echo "=============================================="

echo "📋 Все импорты:"
grep -n "require(" server.js

echo ""
echo "📊 ЭТАП 3: Проверка package.json..."
echo "================================="

if [ -f "package.json" ]; then
    echo "✅ package.json найден"
    echo "📋 Содержимое package.json:"
    cat package.json
else
    echo "❌ package.json не найден"
fi

echo ""
echo "📊 ЭТАП 4: Проверка node_modules..."
echo "================================="

if [ -d "node_modules" ]; then
    echo "✅ node_modules найден"
    echo "📋 Количество модулей: $(ls node_modules | wc -l)"
    echo "📋 Основные модули:"
    ls node_modules | grep -E "^(express|cors|pg|path)$" || echo "Основные модули не найдены"
else
    echo "❌ node_modules не найден"
fi

echo ""
echo "📊 ЭТАП 5: Проверка конкретных модулей..."
echo "======================================"

for module in "express" "cors" "pg" "path"; do
    if [ -d "node_modules/$module" ]; then
        echo "✅ $module найден"
    else
        echo "❌ $module не найден"
    fi
done

echo ""
echo "📊 ЭТАП 6: Проверка config.js..."
echo "============================="

if [ -f "config.js" ]; then
    echo "✅ config.js найден"
    echo "📋 Содержимое config.js:"
    cat config.js
else
    echo "❌ config.js не найден"
fi

echo ""
echo "📊 ЭТАП 7: Тестирование синтаксиса server.js..."
echo "============================================="

echo "📋 Проверка синтаксиса:"
node -c server.js 2>&1

echo ""
echo "📊 ЭТАП 8: Попытка запуска server.js вручную..."
echo "==========================================="

echo "📋 Запуск server.js (5 секунд):"
timeout 5 node server.js 2>&1 || echo "Процесс завершен по таймауту или с ошибкой"

echo ""
echo "📊 ЭТАП 9: Проверка версии Node.js..."
echo "=================================="

node --version

echo ""
echo "📊 ЭТАП 10: Проверка прав доступа..."
echo "================================="

echo "📋 Права на файлы:"
ls -la server.js package.json config.js 2>/dev/null || echo "Файлы не найдены"

echo ""
echo "📊 ЭТАП 11: Проверка зависимостей..."
echo "================================="

echo "📋 Проверяем основные модули:"
for module in "express" "cors" "pg" "path"; do
    if [ -d "node_modules/$module" ]; then
        echo "✅ $module найден"
    else
        echo "❌ $module не найден"
    fi
done

echo ""
echo "📊 ЭТАП 12: Проверка импортов в строке 48..."
echo "========================================="

echo "📋 Строка 48:"
sed -n '48p' server.js

echo "📋 Контекст строки 48:"
sed -n '45,50p' server.js

echo "📋 Поиск проблемных импортов:"
grep -n "require.*admin" server.js || echo "Импорты admin не найдены"
grep -n "require.*WinnerRatingsService" server.js || echo "Импорт WinnerRatingsService не найден"
grep -n "require.*admin-server" server.js || echo "Импорт admin-server не найден"

echo ""
echo "✅ ДИАГНОСТИКА ЗАВЕРШЕНА!"
echo "========================="
echo "💡 Проанализируйте результаты выше для определения проблемы"
echo "💡 Если проблема в строке 48, возможно там есть импорт admin модулей"
