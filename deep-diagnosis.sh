#!/bin/bash

# Глубокая диагностика проблемы с каталогом
# Выясняет что именно происходит на сервере

echo "🔍 ГЛУБОКАЯ ДИАГНОСТИКА ПРОБЛЕМЫ..."
echo "=================================="

# Проверяем, что мы на сервере
if [ ! -f "/var/www/wolmar-parser/server.js" ]; then
    echo "❌ Ошибка: Скрипт должен запускаться на сервере в /var/www/wolmar-parser"
    exit 1
fi

cd /var/www/wolmar-parser

echo "📊 ЭТАП 1: Полная диагностика системы..."
echo "====================================="

echo "🔍 Текущая директория:"
pwd

echo ""
echo "🔍 Текущая ветка Git:"
git branch --show-current

echo ""
echo "🔍 Статус Git:"
git status --porcelain

echo ""
echo "🔍 PM2 процессы:"
pm2 status

echo ""
echo "🔍 Процессы на портах:"
netstat -tlnp | grep -E ":(3000|3001)"

echo ""
echo "🔍 Все Node.js процессы:"
ps aux | grep node | grep -v grep

echo ""
echo "📊 ЭТАП 2: Проверка содержимого портов..."
echo "======================================"

echo "🌐 Проверка порта 3001 (основной сервер):"
echo "📋 HTTP статус:"
curl -I http://localhost:3001/ 2>/dev/null | head -1 || echo "Не удалось подключиться"

echo "📋 Заголовок страницы:"
curl -s http://localhost:3001/ | grep -o '<title>.*</title>' || echo "Заголовок не найден"

echo "📋 API health:"
curl -s http://localhost:3001/api/health || echo "API не отвечает"

echo ""
echo "🌐 Проверка порта 3000 (каталог):"
echo "📋 HTTP статус:"
curl -I http://localhost:3000/ 2>/dev/null | head -1 || echo "Не удалось подключиться"

echo "📋 Заголовок страницы:"
curl -s http://localhost:3000/ | grep -o '<title>.*</title>' || echo "Заголовок не найден"

echo "📋 API каталога:"
curl -s http://localhost:3000/api/auctions || echo "API не отвечает"

echo ""
echo "📊 ЭТАП 3: Сравнение содержимого..."
echo "================================="

echo "📋 Первые 10 строк порта 3001:"
curl -s http://localhost:3001/ | head -10

echo ""
echo "📋 Первые 10 строк порта 3000:"
curl -s http://localhost:3000/ | head -10

echo ""
echo "📊 ЭТАП 4: Проверка файлов каталога..."
echo "==================================="

echo "🔍 Проверка директории каталога:"
ls -la /var/www/catalog-interface/ 2>/dev/null || echo "Директория каталога не найдена"

echo ""
echo "🔍 Проверка server.js каталога:"
if [ -f "/var/www/catalog-interface/server.js" ]; then
    echo "✅ server.js каталога найден"
    echo "📋 Размер файла: $(wc -l < /var/www/catalog-interface/server.js) строк"
    echo "📋 Первые 5 строк:"
    head -5 /var/www/catalog-interface/server.js
    echo "📋 Поиск порта 3000:"
    grep -n "3000" /var/www/catalog-interface/server.js || echo "Порт 3000 не найден"
else
    echo "❌ server.js каталога не найден"
fi

echo ""
echo "🔍 Проверка package.json каталога:"
if [ -f "/var/www/catalog-interface/package.json" ]; then
    echo "✅ package.json каталога найден"
    echo "📋 Содержимое:"
    cat /var/www/catalog-interface/package.json
else
    echo "❌ package.json каталога не найден"
fi

echo ""
echo "📊 ЭТАП 5: Проверка логов..."
echo "=========================="

echo "📋 Логи основного сервера:"
pm2 logs wolmar-parser --lines 5 2>/dev/null || echo "Логи основного сервера не найдены"

echo ""
echo "📋 Логи каталога:"
pm2 logs catalog-interface --lines 5 2>/dev/null || echo "Логи каталога не найдены"

echo ""
echo "📊 ЭТАП 6: Проверка конфигурации..."
echo "================================="

echo "🔍 Проверка config.js каталога:"
if [ -f "/var/www/catalog-interface/config.js" ]; then
    echo "✅ config.js каталога найден"
    echo "📋 Содержимое:"
    cat /var/www/catalog-interface/config.js
else
    echo "❌ config.js каталога не найден"
fi

echo ""
echo "📊 ЭТАП 7: Проверка зависимостей..."
echo "================================="

echo "🔍 Проверка node_modules каталога:"
if [ -d "/var/www/catalog-interface/node_modules" ]; then
    echo "✅ node_modules каталога найден"
    echo "📋 Количество модулей: $(ls /var/www/catalog-interface/node_modules | wc -l)"
else
    echo "❌ node_modules каталога не найден"
fi

echo ""
echo "📊 ЭТАП 8: Тестирование запуска каталога..."
echo "========================================"

echo "🔍 Попытка запуска каталога вручную:"
cd /var/www/catalog-interface 2>/dev/null || echo "Не удалось перейти в директорию каталога"

if [ -f "server.js" ]; then
    echo "📋 Тестирование синтаксиса:"
    node -c server.js 2>&1 || echo "Ошибка синтаксиса"
    
    echo "📋 Попытка запуска (5 секунд):"
    timeout 5 node server.js 2>&1 || echo "Процесс завершен по таймауту или с ошибкой"
else
    echo "❌ server.js каталога не найден"
fi

echo ""
echo "📊 ЭТАП 9: Проверка внешнего доступа..."
echo "===================================="

echo "🌐 Проверка внешнего доступа к порту 3001:"
curl -I http://46.173.19.68:3001/ 2>/dev/null | head -1 || echo "Внешний доступ к порту 3001 недоступен"

echo "🌐 Проверка внешнего доступа к порту 3000:"
curl -I http://46.173.19.68:3000/ 2>/dev/null | head -1 || echo "Внешний доступ к порту 3000 недоступен"

echo ""
echo "✅ ГЛУБОКАЯ ДИАГНОСТИКА ЗАВЕРШЕНА!"
echo "================================="
echo "💡 Проанализируйте результаты выше для определения проблемы"
echo "💡 Если проблема неясна, запустите ./radical-fix-catalog.sh"
