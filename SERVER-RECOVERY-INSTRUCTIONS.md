# 🚀 Инструкции для восстановления на сервере

## Проблема
На сервере ветка `main-website` не найдена. Нужно обновить информацию о ветках.

## Решение на сервере:

### 1. Подключитесь к серверу:
```bash
ssh root@46.173.19.68
cd /var/www/wolmar-parser
```

### 2. Обновите информацию о ветках:
```bash
git fetch origin
```

### 3. Проверьте доступные ветки:
```bash
git branch -a
```

### 4. Переключитесь на ветку main-website:
```bash
git checkout main-website
```

### 5. Получите последние изменения:
```bash
git pull origin main-website
```

### 6. Остановите все процессы:
```bash
pm2 stop all
pm2 delete all
```

### 7. Запустите основной сайт:
```bash
pm2 start server.js --name wolmar-parser
pm2 start admin-server.js --name admin-server
pm2 save
```

### 8. Проверьте результат:
```bash
pm2 status
curl http://localhost:3001
```

## Альтернативный способ (если не работает):

### Если ветка все еще не найдена:
```bash
# Создайте ветку локально на сервере
git checkout -b main-website
git pull origin main-website
```

### Или переключитесь на web-interface:
```bash
git checkout web-interface
git pull origin web-interface
```

## Проверка работы:
- **Основной сайт**: http://46.173.19.68:3001
- **Админ панель**: http://46.173.19.68:3001/admin






