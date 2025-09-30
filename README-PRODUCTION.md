# 🚀 Wolmar Parser - Production Ready

## 📋 Обзор проекта

**Wolmar Parser** - это комплексная система для парсинга аукционов нумизматики с веб-интерфейсом каталога и системой пользовательских коллекций.

### 🎯 Основные возможности:
- **Парсинг аукционов** - автоматический сбор данных с аукционных сайтов
- **Каталог монет** - веб-интерфейс для просмотра и поиска монет
- **Пользовательские коллекции** - система "Моя коллекция" с прогнозированием цен
- **Аналитика** - статистика и аналитические инструменты
- **API** - RESTful API для интеграции с внешними системами

## 🏗 Архитектура

### Основные компоненты:
- **server.js** - основной сервер (порт 3001)
- **catalog-server.js** - сервер каталога (порт 3000)
- **admin-server.js** - административный интерфейс
- **catalog-parser.js** - парсер аукционов
- **collection-service.js** - сервис коллекций
- **collection-price-service.js** - сервис прогнозирования цен

### База данных:
- **PostgreSQL** (Supabase)
- Таблицы: `coin_catalog`, `auction_lots`, `collection_users`, `user_collections`

## 🚀 Быстрый старт

### 1. Требования
- Node.js 18+
- npm 8+
- PM2
- Google Chrome/Chromium
- PostgreSQL (Supabase)

### 2. Установка
```bash
# Клонирование репозитория
git clone https://github.com/wolmar/wolmar-parser.git
cd wolmar-parser

# Установка зависимостей
npm install --production

# Настройка переменных окружения
cp env.example .env
nano .env
```

### 3. Запуск
```bash
# Автоматический запуск
./deploy.sh

# Или ручной запуск
./start-production.sh
```

### 4. Проверка
```bash
# Статус процессов
pm2 status

# Логи
pm2 logs

# Веб-интерфейс
# Основной сервер: http://localhost:3001
# Каталог: http://localhost:3000
```

## 🔧 Управление

### Основные команды:
```bash
# Запуск
./start-production.sh

# Остановка
./stop-production.sh

# Перезапуск
./restart-production.sh

# Полный деплой
./deploy.sh
```

### PM2 команды:
```bash
pm2 status          # Статус процессов
pm2 logs            # Просмотр логов
pm2 restart all     # Перезапуск всех процессов
pm2 stop all        # Остановка всех процессов
pm2 monit           # Мониторинг в реальном времени
```

## 📊 Мониторинг

### Логи:
- `logs/main-combined.log` - основной сервер
- `logs/catalog-combined.log` - каталог
- `logs/main-error.log` - ошибки основного сервера
- `logs/catalog-error.log` - ошибки каталога

### Метрики:
- Использование памяти
- Загрузка CPU
- Количество соединений с БД
- Статистика парсинга

## 🔒 Безопасность

### Настройки:
- JWT токены для аутентификации
- Bcrypt для хеширования паролей
- CORS настройки
- Rate limiting
- SSL/TLS поддержка

### Переменные окружения:
```bash
DB_USER=your_db_user
DB_PASSWORD=your_db_password
JWT_SECRET=your_jwt_secret
NODE_ENV=production
```

## 🌐 Веб-интерфейс

### Основной сервер (порт 3001):
- API endpoints
- Административный интерфейс
- Мониторинг парсера

### Каталог (порт 3000):
- Просмотр монет
- Поиск и фильтрация
- Система коллекций
- Прогнозирование цен

## 📈 Производительность

### Оптимизации:
- Пул соединений с БД
- Кэширование запросов
- Сжатие ответов
- Оптимизация изображений
- Ленивая загрузка

### Масштабирование:
- PM2 кластеризация
- Load balancing
- Горизонтальное масштабирование
- Кэширование на уровне приложения

## 🛠 Разработка

### Структура проекта:
```
wolmar-parser/
├── server.js                 # Основной сервер
├── catalog-server.js         # Сервер каталога
├── admin-server.js           # Административный сервер
├── catalog-parser.js         # Парсер аукционов
├── collection-service.js      # Сервис коллекций
├── collection-price-service.js # Сервис прогнозирования
├── metals-price-service.js   # Сервис цен на металлы
├── winner-ratings-service.js # Сервис рейтингов
├── improved-predictions-generator.js # Генератор прогнозов
├── catalog-public/           # Публичные файлы
├── logs/                     # Логи
├── ecosystem.config.js       # PM2 конфигурация
├── package.json              # Зависимости
└── config.js                 # Конфигурация
```

### API Endpoints:
- `GET /api/coins` - список монет
- `GET /api/coins/:id` - детали монеты
- `POST /api/collection/add` - добавить в коллекцию
- `GET /api/collection` - получить коллекцию
- `POST /api/collection/recalculate-prices` - пересчитать цены

## 🔄 Обновления

### Процесс обновления:
```bash
# Остановка
./stop-production.sh

# Обновление кода
git pull origin main
npm install --production

# Запуск
./start-production.sh
```

### Резервное копирование:
- Автоматические бэкапы БД
- Резервное копирование конфигурации
- Версионирование кода

## 📞 Поддержка

### При возникновении проблем:
1. Проверьте логи: `pm2 logs`
2. Проверьте статус: `pm2 status`
3. Перезапустите: `pm2 restart all`
4. Обратитесь к документации

### Полезные команды:
```bash
# Проверка портов
netstat -tlnp | grep :300

# Проверка процессов
ps aux | grep node

# Очистка логов
pm2 flush
```

## 📚 Документация

- **DEPLOYMENT-GUIDE.md** - подробное руководство по развертыванию
- **API Documentation** - документация API
- **Database Schema** - схема базы данных
- **Configuration Guide** - руководство по настройке

## 🏷 Версии

- **v2.0.0** - текущая версия
- **v1.0.0** - первая версия

## 📄 Лицензия

MIT License

---

**Автор**: Wolmar Team  
**Версия**: 2.0.0  
**Дата**: $(date)  
**Статус**: Production Ready ✅
