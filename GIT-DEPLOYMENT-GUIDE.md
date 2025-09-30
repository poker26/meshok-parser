# 🚀 Wolmar Parser - Развертывание через Git

## 📋 Git-based Deployment Guide

Этот документ описывает процесс развертывания Wolmar Parser на сервере через Git, что является более профессиональным и надежным подходом.

## 🏗 Подготовка сервера

### 1. Установка зависимостей
```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Установка PM2
sudo npm install -g pm2

# Установка Google Chrome
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
sudo apt install -y google-chrome-stable

# Установка Git (если не установлен)
sudo apt install git -y
```

### 2. Создание пользователя для приложения
```bash
# Создание пользователя
sudo adduser wolmar
sudo usermod -aG sudo wolmar

# Переключение на пользователя
sudo su - wolmar
```

## 📦 Клонирование репозитория

### 1. Клонирование проекта
```bash
# Клонирование репозитория
git clone https://github.com/wolmar/wolmar-parser.git
cd wolmar-parser

# Переключение на нужную ветку (если не main)
git checkout main
```

### 2. Настройка переменных окружения
```bash
# Копирование примера конфигурации
cp env.example .env

# Редактирование конфигурации
nano .env
```

### 3. Установка зависимостей
```bash
# Установка production зависимостей
npm install --production

# Создание необходимых директорий
mkdir -p logs catalog-images catalog-public backup
```

## 🚀 Первоначальный запуск

### 1. Запуск приложения
```bash
# Запуск через PM2
pm2 start ecosystem.config.js

# Настройка автозапуска
pm2 startup
pm2 save
```

### 2. Проверка работы
```bash
# Статус процессов
pm2 status

# Просмотр логов
pm2 logs

# Проверка портов
netstat -tlnp | grep :300
```

## 🔄 Процесс обновления

### 1. Остановка приложения
```bash
# Остановка всех процессов
pm2 stop all
```

### 2. Обновление кода
```bash
# Получение последних изменений
git pull origin main

# Установка новых зависимостей (если есть)
npm install --production
```

### 3. Запуск обновленного приложения
```bash
# Запуск процессов
pm2 start ecosystem.config.js

# Или перезапуск
pm2 restart all
```

## 🛠 Скрипты для автоматизации

### 1. Создание скрипта обновления
```bash
nano update.sh
```

Содержимое `update.sh`:
```bash
#!/bin/bash

# Wolmar Parser - Скрипт обновления
set -e

echo "🔄 Обновление Wolmar Parser..."

# Остановка процессов
echo "🛑 Остановка процессов..."
pm2 stop all

# Обновление кода
echo "📥 Получение обновлений..."
git pull origin main

# Установка зависимостей
echo "📦 Установка зависимостей..."
npm install --production

# Запуск процессов
echo "🚀 Запуск процессов..."
pm2 start ecosystem.config.js

# Проверка статуса
echo "📊 Статус процессов:"
pm2 status

echo "✅ Обновление завершено!"
```

### 2. Создание скрипта отката
```bash
nano rollback.sh
```

Содержимое `rollback.sh`:
```bash
#!/bin/bash

# Wolmar Parser - Скрипт отката
set -e

echo "⏪ Откат Wolmar Parser..."

# Остановка процессов
echo "🛑 Остановка процессов..."
pm2 stop all

# Откат к предыдущему коммиту
echo "⏪ Откат к предыдущему коммиту..."
git reset --hard HEAD~1

# Запуск процессов
echo "🚀 Запуск процессов..."
pm2 start ecosystem.config.js

echo "✅ Откат завершен!"
```

### 3. Создание скрипта бэкапа
```bash
nano backup.sh
```

Содержимое `backup.sh`:
```bash
#!/bin/bash

# Wolmar Parser - Скрипт бэкапа
set -e

echo "💾 Создание бэкапа..."

# Создание директории бэкапа
BACKUP_DIR="backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Копирование конфигурации
cp .env "$BACKUP_DIR/"
cp ecosystem.config.js "$BACKUP_DIR/"

# Создание бэкапа базы данных (если нужно)
# pg_dump your_database > "$BACKUP_DIR/database.sql"

# Создание архива
tar -czf "$BACKUP_DIR.tar.gz" "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"

echo "✅ Бэкап создан: $BACKUP_DIR.tar.gz"
```

### 4. Настройка прав доступа
```bash
chmod +x update.sh rollback.sh backup.sh
```

## 🔧 Настройка Git

### 1. Настройка SSH ключей (рекомендуется)
```bash
# Генерация SSH ключа
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Добавление ключа в GitHub
cat ~/.ssh/id_rsa.pub
# Скопируйте содержимое и добавьте в GitHub Settings > SSH Keys
```

### 2. Настройка Git конфигурации
```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

## 📊 Мониторинг и логи

### 1. Настройка логирования
```bash
# Создание директории для логов
mkdir -p logs

# Настройка ротации логов
sudo nano /etc/logrotate.d/wolmar-parser
```

Содержимое `/etc/logrotate.d/wolmar-parser`:
```
/home/wolmar/wolmar-parser/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 wolmar wolmar
    postrotate
        pm2 reloadLogs
    endscript
}
```

### 2. Мониторинг системы
```bash
# Установка htop для мониторинга
sudo apt install htop -y

# Мониторинг в реальном времени
pm2 monit
```

## 🔄 Автоматическое обновление

### 1. Настройка cron для автоматических обновлений
```bash
# Редактирование crontab
crontab -e

# Добавление задачи (обновление каждый день в 3:00)
0 3 * * * cd /home/wolmar/wolmar-parser && ./update.sh >> logs/update.log 2>&1
```

### 2. Настройка webhook для автоматических обновлений
```bash
# Создание webhook скрипта
nano webhook.sh
```

Содержимое `webhook.sh`:
```bash
#!/bin/bash

# Wolmar Parser - Webhook для автоматического обновления
set -e

echo "🔄 Webhook обновление..."

# Проверка, что это POST запрос от GitHub
if [ "$REQUEST_METHOD" != "POST" ]; then
    echo "❌ Только POST запросы"
    exit 1
fi

# Остановка процессов
pm2 stop all

# Обновление кода
git pull origin main

# Установка зависимостей
npm install --production

# Запуск процессов
pm2 start ecosystem.config.js

echo "✅ Webhook обновление завершено!"
```

## 🛡 Безопасность

### 1. Настройка файрвола
```bash
# Установка ufw
sudo apt install ufw -y

# Настройка правил
sudo ufw allow ssh
sudo ufw allow 3000
sudo ufw allow 3001
sudo ufw enable
```

### 2. Настройка SSL (Let's Encrypt)
```bash
# Установка certbot
sudo apt install certbot python3-certbot-nginx -y

# Получение SSL сертификата
sudo certbot --nginx -d your-domain.com
```

## 📞 Устранение неполадок

### 1. Проверка статуса
```bash
# Статус процессов
pm2 status

# Логи
pm2 logs

# Проверка портов
netstat -tlnp | grep :300
```

### 2. Восстановление после сбоя
```bash
# Перезапуск всех процессов
pm2 restart all

# Очистка логов
pm2 flush

# Проверка конфигурации
pm2 show wolmar-main
pm2 show wolmar-catalog
```

### 3. Откат к предыдущей версии
```bash
# Просмотр истории коммитов
git log --oneline

# Откат к конкретному коммиту
git reset --hard <commit-hash>

# Перезапуск
pm2 restart all
```

## 🔧 Полезные команды

### Git команды:
```bash
git status              # Статус репозитория
git log --oneline      # История коммитов
git diff               # Изменения
git stash              # Временное сохранение изменений
git stash pop          # Восстановление изменений
```

### PM2 команды:
```bash
pm2 status             # Статус процессов
pm2 logs               # Просмотр логов
pm2 restart all        # Перезапуск всех
pm2 stop all           # Остановка всех
pm2 delete all         # Удаление всех
pm2 monit              # Мониторинг
pm2 flush              # Очистка логов
```

### Системные команды:
```bash
htop                   # Мониторинг системы
df -h                  # Использование диска
free -h                # Использование памяти
ps aux | grep node     # Процессы Node.js
```

## 📚 Дополнительные ресурсы

- [PM2 Documentation](https://pm2.keymetrics.io/docs/)
- [Git Documentation](https://git-scm.com/doc)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Linux System Administration](https://www.linux.org/)

---

**Версия документации**: 2.0.0  
**Дата обновления**: $(date)  
**Автор**: Wolmar Team
