# Инструкция по настройке проекта Meshok Parser

## 🚀 Быстрый старт

### 1. Создание GitHub репозитория

1. Перейдите на [GitHub](https://github.com) и создайте новый репозиторий:
   - Название: `meshok-parser`
   - Описание: `Parser for Meshok.net auction data - coins price history analysis`
   - Публичный или приватный (на ваш выбор)
   - НЕ добавляйте README, .gitignore или лицензию (они уже есть)

2. Скопируйте URL репозитория (например: `https://github.com/your-username/meshok-parser.git`)

### 2. Настройка на локальной машине

```bash
# Инициализация Git (если еще не инициализирован)
git init

# Добавление всех файлов
git add .

# Первый коммит
git commit -m "Initial project structure for Meshok parser"

# Подключение к GitHub
git remote add origin https://github.com/your-username/meshok-parser.git

# Отправка на GitHub
git push -u origin main
```

### 3. Настройка на сервере

```bash
# Клонирование репозитория
cd ~
git clone https://github.com/your-username/meshok-parser.git
cd meshok-parser

# Установка зависимостей
npm install

# Тестирование
npm run test
```

## 📋 Команды для работы

### Основные команды

```bash
# Тестирование доступа к сайту
npm run test

# Получение списка завершенных лотов (категория 252 - монеты)
npm run fetch:listing

# Получение списка лотов другой категории
node scripts/fetch-listing.js 1106  # СССР 1917-1991

# Получение конкретного лота
node scripts/fetch-item.js 343735645

# Анализ структуры HTML файла
node scripts/analyze-structure.js listing_good252_opt2_2025-10-04.html
```

### Синхронизация изменений

#### С локальной машины на сервер:
```bash
# На локальной машине
git add .
git commit -m "Описание изменений"
git push origin main

# На сервере
git pull origin main
```

#### С сервера на локальную машину:
```bash
# На сервере
git add .
git commit -m "Результаты тестирования"
git push origin main

# На локальной машине
git pull origin main
```

## 🔧 Структура проекта

```
meshok-parser/
├── .gitignore                 # Игнорируемые файлы
├── README.md                  # Основная документация
├── SETUP.md                   # Эта инструкция
├── package.json               # Зависимости и скрипты
├── config/
│   └── categories.json        # Конфигурация категорий
├── scripts/
│   ├── fetch-listing.js      # Получение списка лотов
│   ├── fetch-item.js         # Получение конкретного лота
│   ├── analyze-structure.js  # Анализ HTML структуры
│   └── test-fetch.js         # Тестирование доступа
├── data/
│   └── .gitkeep              # Папка для данных
└── docs/
    ├── research-notes.md      # Заметки исследования
    └── deployment-guide.md    # Руководство по развертыванию
```

## 🧪 Тестирование

### Первый запуск

1. **Проверка доступа к сайту:**
   ```bash
   npm run test
   ```
   Должно показать успешную загрузку страниц без Cloudflare challenge.

2. **Получение списка лотов:**
   ```bash
   npm run fetch:listing
   ```
   Создаст файл в папке `data/` с HTML страницей.

3. **Анализ полученных данных:**
   ```bash
   node scripts/analyze-structure.js <имя_файла>
   ```

### Ожидаемые результаты

- ✅ Страницы загружаются без Cloudflare challenge
- ✅ HTML файлы сохраняются в папку `data/`
- ✅ Находятся ссылки на лоты
- ✅ Извлекается информация о ценах и датах

## 🚨 Troubleshooting

### Проблема: "Failed to launch the browser process!"
**Решение:** Установите системные зависимости для Puppeteer:
```bash
# На сервере выполните:
chmod +x scripts/install-dependencies.sh
./scripts/install-dependencies.sh
```

Или вручную:
```bash
sudo apt-get update
sudo apt-get install -y gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget
```

### Проблема: "Cloudflare challenge detected"
**Решение:** Увеличьте время ожидания в скриптах или проверьте интернет-соединение.

### Проблема: "Нет данных на странице"
**Решение:** Проверьте URL и параметры, возможно изменилась структура сайта.

## 📞 Поддержка

При возникновении проблем:

1. Проверьте логи выполнения скриптов
2. Убедитесь, что все зависимости установлены
3. Проверьте доступность сайта meshok.net
4. Создайте issue в GitHub репозитории с описанием проблемы
