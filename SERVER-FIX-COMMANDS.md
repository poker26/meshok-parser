# 🚨 Команды для исправления на сервере

## Проблема
На сервере есть локальные изменения, которые мешают переключению веток.

## Решение:

### 1. Сохраните локальные изменения:
```bash
git stash push -m "Локальные изменения перед переключением на main-website"
```

### 2. Переключитесь на ветку main-website:
```bash
git checkout main-website
```

### 3. Получите последние изменения:
```bash
git pull origin main-website
```

### 4. Остановите все процессы:
```bash
pm2 stop all
pm2 delete all
```

### 5. Запустите основной сайт:
```bash
pm2 start server.js --name wolmar-parser
pm2 start admin-server.js --name admin-server
pm2 save
```

### 6. Проверьте результат:
```bash
pm2 status
curl http://localhost:3001
```

## Альтернативный способ (если не работает):

### Принудительное переключение:
```bash
git checkout -f main-website
git pull origin main-website
```

### Или сброс всех изменений:
```bash
git reset --hard HEAD
git checkout main-website
git pull origin main-website
```

## Проверка работы:
- **Основной сайт**: http://46.173.19.68:3001
- **Админ панель**: http://46.173.19.68:3001/admin




