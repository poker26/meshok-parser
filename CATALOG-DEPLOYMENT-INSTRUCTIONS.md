# 🚀 Инструкции по развертыванию каталога монет

## ⚠️ ВАЖНО: Основной сайт НЕ ТРОГАЕМ!
- **Порт 3001** - основной сайт аукционов (НЕ ТРОГАЕМ!)
- **Порт 3000** - каталог монет (РАБОТАЕМ ТОЛЬКО С НИМ!)

## 📋 Развертывание на сервере:

### 1. Подключитесь к серверу:
```bash
ssh root@46.173.19.68
cd /var/www/wolmar-parser
```

### 2. Переключитесь на ветку coins:
```bash
git checkout coins
git pull origin coins
```

### 3. Запустите скрипт развертывания:
```bash
chmod +x deploy-catalog-to-server.sh
./deploy-catalog-to-server.sh
```

### 4. Проверьте результат:
```bash
pm2 status
curl http://localhost:3000
```

## 🔍 Проверка работы:

### Основной сайт (НЕ ТРОГАЕМ):
- **URL**: http://46.173.19.68:3001
- **Статус**: Должен работать как обычно

### Каталог монет:
- **URL**: http://46.173.19.68:3000
- **Статус**: Должен показывать интерфейс каталога

## 🛠️ Управление каталогом:

### Остановка каталога:
```bash
pm2 stop catalog-parser
pm2 stop catalog-server
```

### Запуск каталога:
```bash
pm2 start catalog-parser
pm2 start catalog-server
```

### Просмотр логов:
```bash
pm2 logs catalog-parser
pm2 logs catalog-server
```

## 🚨 В случае проблем:

### Если каталог не работает:
```bash
pm2 logs catalog-server
pm2 restart catalog-server
```

### Если основной сайт сломался:
```bash
# НЕМЕДЛЕННО переключитесь на main-website
git checkout main-website
git pull origin main-website
pm2 restart wolmar-parser
pm2 restart admin-server
```

## 📊 Структура проектов:
- **Ветка `main-website`** - основной сайт (порт 3001)
- **Ветка `coins`** - каталог монет (порт 3000)
- **Полное разделение** - проекты не влияют друг на друга






