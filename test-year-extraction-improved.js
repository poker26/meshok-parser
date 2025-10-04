#!/usr/bin/env node

// Тестируем улучшенное извлечение года
function extractYear(description) {
    const result = { year: null };
    
    // Извлекаем год (улучшенная версия)
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
        result.year = parseInt(yearMatch[1]);
        console.log(`🔍 Извлечен год: ${result.year} из "${description}"`);
    }
    
    return result;
}

// Тестовые описания
const testDescriptions = [
    "Печать вислая. Владимир Мономах Pb. | 1113-1125 гг. н.э.",
    "2 копейки Cu. | 1811-1829 гг",
    "20 сенов. Малайзия Cu-Ni. | 2000-2003 гг",
    "15 копеек СПБ НI. Ag. | 1866-1877 гг.",
    "25 копеек 1828 года",
    "20 копеек 1771 года",
    "10000 рублей 2003 года",
    "1/2 афгани. Афганистан St/Ni. | 1952-1953 гг",
    "10 рублей. Брак Cu-Zn 5,69. | Аверс - юбилейная, Грозный (магнитная) / реверс - обычная (тиражная),"
];

console.log('🔍 Тестирование улучшенного извлечения года...\n');

testDescriptions.forEach((desc, index) => {
    console.log(`${index + 1}. "${desc}"`);
    const result = extractYear(desc);
    console.log(`   Результат: ${result.year || 'не найден'}\n`);
});




