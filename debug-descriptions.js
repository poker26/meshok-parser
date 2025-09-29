#!/usr/bin/env node

const testDescriptions = [
    "10 рублей. Грозный - Грозный. Брак Fe 5,73. | Магнитная. Гурт рубчатый.",
    "15 копеек СПБ НI. Ag. | 1866-1877 гг.",
    "20 копеек 1771 года",
    "25 копеек 1828 года",
    "10000 рублей 2003 года",
    "2 копейки Cu. | 1811-1829 гг"
];

console.log('🔍 Отладка описаний...\n');

testDescriptions.forEach((desc, index) => {
    console.log(`${index + 1}. "${desc}"`);
    
    // Проверяем различные варианты
    const patterns = [
        /\b(рублей?|копеек?|руб\.?|коп\.?|руб|коп)\b/i,
        /рублей?/i,
        /копеек?/i,
        /руб/i,
        /коп/i
    ];
    
    patterns.forEach((pattern, i) => {
        const match = desc.match(pattern);
        console.log(`   Паттерн ${i + 1}: ${match ? 'НАЙДЕНО' : 'НЕ НАЙДЕНО'} - ${pattern}`);
    });
    
    console.log('');
});
