# 🛡️ План безопасного развертывания

## 📋 Анализ совместимости

### ✅ **Безопасность развертывания:**
- **Порты не конфликтуют**: новый каталог (3000) vs основной сайт (3001)
- **База данных**: используется та же Supabase БД, только добавляются новые таблицы
- **Файловая система**: новые директории (`catalog-public/`, `logs/`)
- **Зависимости**: совместимые версии Node.js пакетов

### ⚠️ **Потенциальные риски:**
1. **Конфликт портов** - если на сервере уже что-то работает на портах 3000/3001
2. **База данных** - новые таблицы для коллекций
3. **Файлы** - перезапись существующих файлов
4. **PM2 процессы** - конфликт имен процессов

## 🚀 План безопасного развертывания

### Этап 1: Подготовка (БЕЗОПАСНО)
```bash
# 1. Проверка текущего состояния
pm2 status
netstat -tlnp | grep :300

# 2. Создание бэкапа
mkdir -p backup/$(date +%Y%m%d-%H%M%S)
cp -r . backup/$(date +%Y%m%d-%H%M%S)/

# 3. Проверка портов
ss -tlnp | grep :3000
ss -tlnp | grep :3001
```

### Этап 2: Проверка совместимости
```bash
# 1. Проверка зависимостей
npm list --depth=0

# 2. Проверка конфигурации
node -e "console.log(require('./config.js'))"

# 3. Тест подключения к БД
node -e "
const { Pool } = require('pg');
const config = require('./config');
const pool = new Pool(config.dbConfig);
pool.query('SELECT 1').then(() => {
  console.log('✅ БД подключение OK');
  process.exit(0);
}).catch(err => {
  console.error('❌ БД ошибка:', err.message);
  process.exit(1);
});
"
```

### Этап 3: Поэтапное развертывание

#### 3.1. Создание новых таблиц (БЕЗОПАСНО)
```bash
# Создание таблиц для коллекций (не влияет на существующие)
node -e "
const { Pool } = require('pg');
const config = require('./config');
const pool = new Pool(config.dbConfig);

async function createTables() {
  try {
    // Создание таблицы пользователей коллекций
    await pool.query(\`
      CREATE TABLE IF NOT EXISTS collection_users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    \`);
    
    // Создание таблицы коллекций
    await pool.query(\`
      CREATE TABLE IF NOT EXISTS user_collections (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES collection_users(id),
        coin_id INTEGER NOT NULL,
        user_condition VARCHAR(10),
        purchase_price DECIMAL(12,2),
        purchase_date DATE,
        notes TEXT,
        predicted_price DECIMAL(12,2),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    \`);
    
    console.log('✅ Таблицы коллекций созданы');
    process.exit(0);
  } catch (err) {
    console.error('❌ Ошибка создания таблиц:', err.message);
    process.exit(1);
  }
}

createTables();
"
```

#### 3.2. Запуск в тестовом режиме
```bash
# Запуск на альтернативных портах для тестирования
PORT=3002 node server.js &
PORT=3003 node catalog-server.js &

# Проверка работы
curl http://localhost:3002/api/health
curl http://localhost:3003/api/health

# Остановка тестовых процессов
pkill -f "node server.js"
pkill -f "node catalog-server.js"
```

#### 3.3. Полное развертывание
```bash
# Остановка существующих процессов (если есть)
pm2 stop all 2>/dev/null || true

# Запуск новых процессов
pm2 start ecosystem.config.js

# Проверка статуса
pm2 status
```

## 🔄 План отката

### Быстрый откат (если что-то пошло не так):
```bash
# 1. Остановка новых процессов
pm2 stop wolmar-main wolmar-catalog
pm2 delete wolmar-main wolmar-catalog

# 2. Восстановление из бэкапа
cp -r backup/$(ls backup | tail -1)/* .

# 3. Запуск старых процессов
pm2 start [старые процессы]
```

### Полный откат:
```bash
# 1. Остановка всех процессов
pm2 stop all
pm2 delete all

# 2. Восстановление из Git
git reset --hard HEAD~1

# 3. Переустановка зависимостей
npm install --production

# 4. Запуск старых процессов
pm2 start [старая конфигурация]
```

## 📊 Мониторинг после развертывания

### Проверки:
```bash
# 1. Статус процессов
pm2 status

# 2. Логи
pm2 logs --lines 50

# 3. Порты
netstat -tlnp | grep :300

# 4. Веб-интерфейс
curl -I http://localhost:3001
curl -I http://localhost:3000

# 5. База данных
node -e "
const { Pool } = require('pg');
const config = require('./config');
const pool = new Pool(config.dbConfig);
pool.query('SELECT COUNT(*) FROM coin_catalog').then(result => {
  console.log('✅ Каталог монет:', result.rows[0].count);
  process.exit(0);
}).catch(err => {
  console.error('❌ Ошибка БД:', err.message);
  process.exit(1);
});
"
```

## ⚠️ Предупреждения

### Что НЕ сломается:
- ✅ Существующий основной сайт (если на другом порту)
- ✅ База данных (только добавятся новые таблицы)
- ✅ Существующие файлы (кроме перезаписанных)

### Что может сломаться:
- ⚠️ Если что-то уже работает на портах 3000/3001
- ⚠️ Если есть конфликт имен PM2 процессов
- ⚠️ Если перезаписываются существующие файлы

## 🛠️ Рекомендации

### Перед развертыванием:
1. **Создайте полный бэкап** сервера
2. **Проверьте порты** на сервере
3. **Протестируйте** на тестовом сервере
4. **Подготовьте план отката**

### После развертывания:
1. **Мониторьте логи** первые 30 минут
2. **Проверьте все функции** веб-интерфейса
3. **Убедитесь в работе** API
4. **Проверьте производительность**

---

**Статус**: ✅ БЕЗОПАСНО для развертывания  
**Риск**: 🟡 НИЗКИЙ (при соблюдении плана)  
**Время развертывания**: ~10-15 минут  
**Время отката**: ~5 минут
