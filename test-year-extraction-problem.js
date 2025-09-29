#!/usr/bin/env node

// Тестируем извлечение года из проблемного описания
function extractYear(description) {
    console.log(`🔍 Анализируем: "${description}"`);
    
    // Текущая логика парсера
    let yearMatch = description.match(/(\d{4})г?\./); // Старый формат: 1900г.
    if (!yearMatch) {
        yearMatch = description.match(/(\d{4})\s*года/); // Новый формат: 1900 года
    }
    if (!yearMatch) {
        yearMatch = description.match(/(\d{4})\s*гг/); // Формат: 1900 гг
    }
    if (!yearMatch) {
        // Пытаемся извлечь первый год из диапазона: 1900-1950 гг
        yearMatch = description.match(/(\d{4})-\d{4}\s*гг/);
    }
    if (!yearMatch) {
        // Пытаемся извлечь первый год из диапазона: 1900-1950 гг. н.э.
        yearMatch = description.match(/(\d{4})-\d{4}\s*гг\.\s*н\.э\./);
    }
    
    if (yearMatch) {
        const year = parseInt(yearMatch[1]);
        console.log(`✅ Найден год: ${year} (паттерн: ${yearMatch[0]})`);
        return year;
    } else {
        console.log(`❌ Год не найден`);
        return null;
    }
}

// Проблемное описание
const problemDescription = "10 копеек. Чеканный блеск 1910г. СПБ ЭБ. Ag. | Санкт-Петербургский монетный двор. Биткин №# 941.162, тираж 20 000 009, Уздеников №# 2180, Казаков №# 382, тираж 49 290 020, рейтинг 31. По каталогу Wolmar # 139/62.";

console.log('🔍 Тестирование извлечения года...\n');
const extractedYear = extractYear(problemDescription);

console.log(`\n📊 Результат:`);
console.log(`   Ожидаемый год: 1910`);
console.log(`   Извлеченный год: ${extractedYear}`);
console.log(`   Совпадает: ${extractedYear === 1910 ? 'ДА' : 'НЕТ'}`);
