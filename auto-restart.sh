#!/bin/bash

# Скрипт автоматического перезапуска сервера
# Запускать через cron каждые 5 минут

SERVER_URL="http://localhost:3001/api/health"
LOG_FILE="/var/log/wolmar-auto-restart.log"
MAX_RETRIES=3
RETRY_DELAY=30

# Функция логирования
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Функция проверки сервера
check_server() {
    local response
    response=$(curl -s -o /dev/null -w "%{http_code}" "$SERVER_URL" 2>/dev/null)
    
    if [ "$response" = "200" ]; then
        return 0  # Сервер работает
    else
        return 1  # Сервер не работает
    fi
}

# Функция перезапуска сервера
restart_server() {
    log "🔄 Перезапуск сервера..."
    
    # Останавливаем PM2 процесс
    pm2 stop wolmar-parser 2>/dev/null
    
    # Ждем 5 секунд
    sleep 5
    
    # Запускаем PM2 процесс
    pm2 start wolmar-parser 2>/dev/null
    
    # Ждем 10 секунд для запуска
    sleep 10
    
    # Проверяем, запустился ли сервер
    if check_server; then
        log "✅ Сервер успешно перезапущен"
        return 0
    else
        log "❌ Ошибка перезапуска сервера"
        return 1
    fi
}

# Функция анализа сбоя и восстановления парсеров
analyze_crash_and_recover() {
    log "🔍 Анализ сбоя и восстановление парсеров..."
    
    # Запускаем анализ сбоя
    if [ -f "analyze-crash-recovery.js" ]; then
        log "📊 Запуск анализа сбоя..."
        node analyze-crash-recovery.js --auto-recovery >> "$LOG_FILE" 2>&1
        
        if [ $? -eq 0 ]; then
            log "✅ Анализ сбоя завершен, парсеры восстановлены"
        else
            log "⚠️ Ошибка анализа сбоя, но сервер перезапущен"
        fi
    else
        log "⚠️ Скрипт анализа сбоя не найден, пропускаем восстановление парсеров"
    fi
}

# Основная логика
log "🔍 Проверка сервера..."

if check_server; then
    log "✅ Сервер работает нормально"
    exit 0
else
    log "❌ Сервер недоступен, начинаем перезапуск..."
    
    # Анализируем сбой и восстанавливаем парсеры
    analyze_crash_and_recover
    
    # Пытаемся перезапустить несколько раз
    for i in $(seq 1 $MAX_RETRIES); do
        log "🔄 Попытка перезапуска $i из $MAX_RETRIES"
        
        if restart_server; then
            log "✅ Сервер успешно перезапущен с попытки $i"
            exit 0
        else
            log "❌ Попытка $i неудачна, ждем $RETRY_DELAY секунд..."
            sleep $RETRY_DELAY
        fi
    done
    
    log "❌ Не удалось перезапустить сервер после $MAX_RETRIES попыток"
    exit 1
fi
