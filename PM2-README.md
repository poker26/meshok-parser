# 🚀 PM2 Мониторинг сервера

## 📋 Описание
PM2 (Process Manager 2) - это продвинутый менеджер процессов для Node.js приложений, который обеспечивает:
- **Автоматический перезапуск** при падении сервера
- **Мониторинг ресурсов** (CPU, память, uptime)
- **Логирование** с ротацией
- **Web-интерфейс** для управления
- **Graceful shutdown** при перезапуске

## 🛠️ Установка и настройка

### 1. Подключение к серверу
```bash
ssh root@46.173.19.68
cd /var/www/wolmar-parser
```

### 2. Установка PM2
```bash
npm install -g pm2
```

### 3. Запуск настройки
```bash
chmod +x setup-pm2.sh
./setup-pm2.sh
```

### 4. Проверка статуса
```bash
pm2 status
pm2 logs wolmar-parser
```

## 📊 Управление сервером

### Основные команды
```bash
# Управление через скрипт
./manage-server.sh start      # Запуск
./manage-server.sh stop       # Остановка
./manage-server.sh restart    # Перезапуск
./manage-server.sh status     # Статус
./manage-server.sh logs       # Логи
./manage-server.sh monit      # Мониторинг
./manage-server.sh health     # Проверка здоровья
./manage-server.sh update     # Обновление с git
```

### Прямые команды PM2
```bash
pm2 start ecosystem.config.js    # Запуск
pm2 stop wolmar-parser           # Остановка
pm2 restart wolmar-parser       # Перезапуск
pm2 reload wolmar-parser         # Graceful reload
pm2 delete wolmar-parser         # Удаление
pm2 save                         # Сохранить конфигурацию
pm2 resurrect                    # Восстановить процессы
```

## 📈 Мониторинг

### Статус процессов
```bash
pm2 status
```

### Логи в реальном времени
```bash
pm2 logs wolmar-parser
pm2 logs wolmar-parser --lines 100
```

### Мониторинг ресурсов
```bash
pm2 monit
```

### Health check
```bash
curl http://localhost:3001/api/health
```

## 🔧 Конфигурация

### Файл ecosystem.config.js
- **Автоматический перезапуск** при ошибках
- **Мониторинг ресурсов** (CPU, память)
- **Логирование** с ротацией
- **Health check** каждые 30 секунд
- **Graceful shutdown** при перезапуске
- **Перезапуск по расписанию** (каждый день в 3:00)

### Логи
- **Общие логи**: `./logs/combined.log`
- **Вывод**: `./logs/out.log`
- **Ошибки**: `./logs/error.log`
- **Ротация**: автоматическая при достижении 10MB
- **Архивирование**: 30 дней

## 🚨 Уведомления

### Настройка уведомлений
```bash
pm2 install pm2-slack
pm2 set pm2-slack:webhook_url "YOUR_SLACK_WEBHOOK"
pm2 set pm2-slack:channel "#alerts"
```

### Email уведомления
```bash
pm2 install pm2-mail
pm2 set pm2-mail:to "admin@example.com"
pm2 set pm2-mail:from "noreply@example.com"
```

## 📊 Web-интерфейс

### PM2 Plus (локально)
```bash
pm2 plus
# Открыть: http://localhost:9615
```

### Удаленный мониторинг
```bash
pm2 plus
# Настроить удаленный доступ
```

## 🔄 Автоматизация

### Автозапуск при перезагрузке
```bash
pm2 startup
pm2 save
```

### Cron задачи
```bash
# Добавить в crontab
0 3 * * * cd /var/www/wolmar-parser && pm2 restart wolmar-parser
```

## 🛠️ Troubleshooting

### Проблемы с запуском
```bash
pm2 logs wolmar-parser --lines 100
pm2 describe wolmar-parser
```

### Проблемы с памятью
```bash
pm2 restart wolmar-parser
pm2 monit
```

### Проблемы с портом
```bash
netstat -tulpn | grep 3001
lsof -i :3001
```

## 📋 Полезные команды

### Резервное копирование
```bash
./manage-server.sh backup-logs
```

### Очистка логов
```bash
./manage-server.sh clean-logs
```

### Обновление сервера
```bash
./manage-server.sh update
```

### Проверка здоровья
```bash
./manage-server.sh health
```

## 🎯 Результат

После настройки PM2 вы получите:
- ✅ **Автоматический перезапуск** при падении сервера
- ✅ **Мониторинг ресурсов** в реальном времени
- ✅ **Логирование** с ротацией и архивированием
- ✅ **Web-интерфейс** для управления
- ✅ **Уведомления** о проблемах
- ✅ **Graceful shutdown** при перезапуске
- ✅ **Автозапуск** при перезагрузке сервера
