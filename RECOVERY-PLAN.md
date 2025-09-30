# 🔄 ПЛАН ВОССТАНОВЛЕНИЯ И РЕОРГАНИЗАЦИИ

## Текущая ситуация:
- Ветка `catalog-parser` содержит основной сайт + каталог
- Нужно восстановить состояние до начала работы с каталогом
- Создать отдельную ветку для каталога
- Переименовать `catalog-parser` в `main-website`

## План действий:

### 1. Создать резервную копию текущего состояния:
```bash
git checkout catalog-parser
git branch catalog-parser-backup
```

### 2. Найти коммит до начала работы с каталогом:
```bash
# Ищем коммит до добавления файлов каталога
git log --oneline --grep="каталог" --reverse | head -1
```

### 3. Восстановить catalog-parser до этого коммита:
```bash
git reset --hard <commit-hash>
```

### 4. Создать ветку coins для каталога:
```bash
git checkout catalog-parser-backup
git checkout -b coins
```

### 5. Переименовать catalog-parser в main-website:
```bash
git checkout catalog-parser
git branch -m main-website
```

### 6. Отправить изменения:
```bash
git push origin main-website
git push origin coins
git push origin :catalog-parser  # удалить старую ветку
```

## Результат:
- `main-website` - основной сайт без каталога
- `coins` - каталог монет
- `catalog-parser` - удалена
