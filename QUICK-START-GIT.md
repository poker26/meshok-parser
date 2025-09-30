# 🚀 Wolmar Parser - Быстрый старт с Git

## 📋 Быстрая установка через Git

### 1. Подготовка сервера
```bash
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
```

### 2. Клонирование и настройка
```bash
# Клонирование репозитория
git clone https://github.com/wolmar/wolmar-parser.git
cd wolmar-parser

# Настройка переменных окружения
cp env.example .env
nano .env  # Настройте переменные

# Установка зависимостей
npm install --production

# Создание директорий
mkdir -p logs catalog-images catalog-public backup
```

### 3. Запуск
```bash
# Автоматический запуск
./git-deploy.sh

# Или ручной запуск
pm2 start ecosystem.config.js
pm2 startup
pm2 save
```

### 4. Проверка
```bash
# Статус
pm2 status

# Логи
pm2 logs

# Веб-интерфейс
# Основной сервер: http://localhost:3001
# Каталог: http://localhost:3000
```

## 🔄 Обновление

### Автоматическое обновление
```bash
# Обновление через скрипт
./git-update.sh
```

### Ручное обновление
```bash
# Остановка процессов
pm2 stop all

# Получение обновлений
git pull origin main

# Установка зависимостей
npm install --production

# Запуск процессов
pm2 start ecosystem.config.js
```

## ⏪ Откат

### Откат к предыдущей версии
```bash
# Интерактивный откат
./git-rollback.sh
```

### Ручной откат
```bash
# Просмотр истории
git log --oneline

# Откат к конкретному коммиту
git reset --hard <commit-hash>

# Перезапуск
pm2 restart all
```

## 🔧 Управление

### Основные команды
```bash
pm2 status              # Статус процессов
pm2 logs                # Просмотр логов
pm2 restart all         # Перезапуск всех
pm2 stop all            # Остановка всех
pm2 monit               # Мониторинг
```

### Git команды
```bash
git status              # Статус репозитория
git log --oneline      # История коммитов
git diff               # Изменения
git stash              # Временное сохранение
git stash pop          # Восстановление
```

## 📊 Мониторинг

### Логи
- `logs/main-combined.log` - основной сервер
- `logs/catalog-combined.log` - каталог
- `logs/main-error.log` - ошибки основного сервера
- `logs/catalog-error.log` - ошибки каталога

### Метрики
```bash
# Мониторинг системы
htop

# Использование диска
df -h

# Использование памяти
free -h

# Процессы Node.js
ps aux | grep node
```

## 🛠 Устранение неполадок

### Проверка статуса
```bash
# Статус процессов
pm2 status

# Логи
pm2 logs

# Проверка портов
netstat -tlnp | grep :300
```

### Восстановление
```bash
# Перезапуск всех процессов
pm2 restart all

# Очистка логов
pm2 flush

# Проверка конфигурации
pm2 show wolmar-main
pm2 show wolmar-catalog
```

### Откат при проблемах
```bash
# Откат к предыдущей версии
./git-rollback.sh

# Или ручной откат
git reset --hard HEAD~1
pm2 restart all
```

## 🔄 Автоматизация

### Настройка cron для автоматических обновлений
```bash
# Редактирование crontab
crontab -e

# Добавление задачи (обновление каждый день в 3:00)
0 3 * * * cd /path/to/wolmar-parser && ./git-update.sh >> logs/update.log 2>&1
```

### Настройка webhook для автоматических обновлений
```bash
# Создание webhook скрипта
nano webhook.sh
chmod +x webhook.sh
```

Содержимое `webhook.sh`:
```bash
#!/bin/bash
cd /path/to/wolmar-parser
./git-update.sh
```

## 📚 Дополнительные ресурсы

- **GIT-DEPLOYMENT-GUIDE.md** - подробное руководство по Git развертыванию
- **DEPLOYMENT-GUIDE.md** - общее руководство по развертыванию
- **README-PRODUCTION.md** - документация для production

## 🆘 Поддержка

При возникновении проблем:
1. Проверьте логи: `pm2 logs`
2. Проверьте статус: `pm2 status`
3. Перезапустите: `pm2 restart all`
4. Откатитесь: `./git-rollback.sh`
5. Обратитесь к документации

---

**Версия документации**: 2.0.0  
**Дата обновления**: $(date)  
**Автор**: Wolmar Team
