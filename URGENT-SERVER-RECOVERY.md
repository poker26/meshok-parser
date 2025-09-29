# 🚨 СРОЧНОЕ ВОССТАНОВЛЕНИЕ СЕРВЕРА

## Проблема
Основной сайт аукционов сломался при обновлении каталога. Нужно срочно восстановить.

## Немедленные действия на сервере:

### 1. Подключитесь к серверу:
```bash
ssh root@46.173.19.68
cd /var/www/wolmar-parser
```

### 2. Остановите все процессы:
```bash
pm2 stop all
pm2 delete all
```

### 3. Переключитесь на основную ветку:
```bash
git checkout main
git pull origin main
```

### 4. Установите зависимости:
```bash
npm install
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

## Проверка работы:
- **Основной сайт**: http://46.173.19.68:3001
- **Админ панель**: http://46.173.19.68:3001/admin

## Если не работает, попробуйте:
```bash
# Полная перезагрузка
pm2 restart all
# Или
pm2 reload all
```

## После восстановления основного сайта:
1. Каталог будет в отдельной ветке `catalog-monet`
2. Основной сайт останется в ветке `main`
3. Проекты будут полностью разделены

## Команды для разделения проектов:
```bash
# На локальной машине
git checkout main
git pull origin main
./separate-projects.sh
```
