#!/bin/bash

# Глубокая диагностика ошибки MODULE_NOT_FOUND в каталоге
# Анализирует все возможные причины ошибки

echo "🔍 ГЛУБОКАЯ ДИАГНОСТИКА ОШИБКИ MODULE_NOT_FOUND..."
echo "==============================================="

cd /var/www/catalog-interface

echo "📊 ЭТАП 1: Анализ строки 48 и контекста..."
echo "========================================"

if [ -f "server.js" ]; then
    echo "📋 Строка 48:"
    sed -n '48p' server.js
    echo ""
    echo "📋 Контекст строки 48 (строки 45-50):"
    sed -n '45,50p' server.js
    echo ""
    echo "📋 Контекст строки 48 (строки 40-55):"
    sed -n '40,55p' server.js
else
    echo "❌ server.js не найден"
    exit 1
fi

echo ""
echo "📊 ЭТАП 2: Поиск всех require() в файле..."
echo "========================================"

echo "📋 Все импорты с номерами строк:"
grep -n "require(" server.js

echo ""
echo "📊 ЭТАП 3: Анализ package.json..."
echo "==============================="

if [ -f "package.json" ]; then
    echo "📋 Содержимое package.json:"
    cat package.json
    echo ""
    echo "📋 Проверка зависимостей:"
    if [ -f "package.json" ]; then
        echo "📋 Зависимости из package.json:"
        grep -A 20 '"dependencies"' package.json || echo "Секция dependencies не найдена"
    fi
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
    ls node_modules | head -20
    echo ""
    echo "📋 Проверка конкретных модулей:"
    for module in "express" "cors" "pg" "path"; do
        if [ -d "node_modules/$module" ]; then
            echo "✅ $module найден"
            echo "📋 Версия $module:"
            if [ -f "node_modules/$module/package.json" ]; then
                grep '"version"' node_modules/$module/package.json || echo "Версия не найдена"
            fi
        else
            echo "❌ $module не найден"
        fi
    done
else
    echo "❌ node_modules не найден"
fi

echo ""
echo "📊 ЭТАП 5: Проверка файлов конфигурации..."
echo "======================================="

echo "📋 Проверка config.js:"
if [ -f "config.js" ]; then
    echo "✅ config.js найден"
    echo "📋 Содержимое config.js:"
    cat config.js
else
    echo "❌ config.js не найден"
fi

echo ""
echo "📋 Проверка других конфигурационных файлов:"
for file in "config.production.js" "config.example.js" ".env" ".env.local"; do
    if [ -f "$file" ]; then
        echo "✅ $file найден"
    else
        echo "❌ $file не найден"
    fi
done

echo ""
echo "📊 ЭТАП 6: Тестирование синтаксиса..."
echo "=================================="

echo "📋 Проверка синтаксиса server.js:"
node -c server.js 2>&1

echo ""
echo "📋 Попытка запуска server.js (10 секунд):"
timeout 10 node server.js 2>&1 || echo "Процесс завершен по таймауту или с ошибкой"

echo ""
echo "📊 ЭТАП 7: Проверка версии Node.js и npm..."
echo "========================================"

echo "📋 Версия Node.js:"
node --version

echo "📋 Версия npm:"
npm --version

echo "📋 Версия PM2:"
pm2 --version

echo ""
echo "📊 ЭТАП 8: Проверка прав доступа..."
echo "================================="

echo "📋 Права на файлы:"
ls -la server.js package.json config.js 2>/dev/null || echo "Файлы не найдены"

echo "📋 Права на директории:"
ls -la . | head -10

echo ""
echo "📊 ЭТАП 9: Проверка переменных окружения..."
echo "======================================="

echo "📋 Переменные окружения:"
env | grep -E "(NODE|PATH|HOME)" | head -10

echo ""
echo "📊 ЭТАП 10: Проверка процессов Node.js..."
echo "====================================="

echo "📋 Процессы Node.js:"
ps aux | grep node | grep -v grep || echo "Процессы Node.js не найдены"

echo ""
echo "📊 ЭТАП 11: Проверка PM2 процессов..."
echo "=================================="

echo "📋 Статус PM2:"
pm2 status

echo "📋 Логи PM2:"
pm2 logs --lines 5

echo ""
echo "📊 ЭТАП 12: Проверка портов..."
echo "============================"

echo "📋 Процессы на портах 3000-3001:"
netstat -tlnp | grep -E ":300[01]" || echo "Порты 3000-3001 не заняты"

echo ""
echo "📊 ЭТАП 13: Проверка логов каталога..."
echo "==================================="

echo "📋 Логи каталога:"
pm2 logs catalog-interface --lines 20 2>/dev/null || echo "Логи каталога не найдены"

echo ""
echo "📊 ЭТАП 14: Проверка содержимого server.js по частям..."
echo "==================================================="

echo "📋 Первые 20 строк server.js:"
head -20 server.js

echo ""
echo "📋 Строки 40-60 server.js:"
sed -n '40,60p' server.js

echo ""
echo "📋 Последние 20 строк server.js:"
tail -20 server.js

echo ""
echo "📊 ЭТАП 15: Поиск проблемных строк..."
echo "=================================="

echo "📋 Поиск строк с 'require':"
grep -n "require" server.js

echo ""
echo "📋 Поиск строк с 'import':"
grep -n "import" server.js

echo ""
echo "📋 Поиск строк с 'module':"
grep -n "module" server.js

echo ""
echo "📊 ЭТАП 16: Проверка зависимостей в package.json..."
echo "================================================"

if [ -f "package.json" ]; then
    echo "📋 Зависимости:"
    grep -A 50 '"dependencies"' package.json || echo "Секция dependencies не найдена"
    
    echo "📋 Dev зависимости:"
    grep -A 50 '"devDependencies"' package.json || echo "Секция devDependencies не найдена"
fi

echo ""
echo "📊 ЭТАП 17: Проверка установленных пакетов..."
echo "=========================================="

echo "📋 Установленные пакеты:"
npm list --depth=0 2>/dev/null || echo "Ошибка получения списка пакетов"

echo ""
echo "📊 ЭТАП 18: Проверка кэша npm..."
echo "=============================="

echo "📋 Очистка кэша npm:"
npm cache clean --force

echo ""
echo "📊 ЭТАП 19: Переустановка зависимостей..."
echo "======================================"

echo "📋 Удаление node_modules:"
rm -rf node_modules package-lock.json

echo "📋 Установка зависимостей:"
npm install

echo ""
echo "📊 ЭТАП 20: Финальная проверка..."
echo "=============================="

echo "📋 Проверка синтаксиса после переустановки:"
node -c server.js 2>&1

echo "📋 Попытка запуска после переустановки (5 секунд):"
timeout 5 node server.js 2>&1 || echo "Процесс завершен по таймауту или с ошибкой"

echo ""
echo "✅ ГЛУБОКАЯ ДИАГНОСТИКА ЗАВЕРШЕНА!"
echo "================================="
echo "💡 Проанализируйте результаты выше для определения проблемы"
echo "💡 Если проблема не найдена, возможно нужно пересоздать server.js с нуля"
