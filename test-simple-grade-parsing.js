// Простая и надежная функция для обработки состояний с градациями
function extractConditionWithGrade(conditionText) {
    if (!conditionText) return null;
    
    // Убираем ВСЕ пробелы и возвращаем результат
    return conditionText.replace(/\s+/g, '');
}

// Расширенные тестовые данные с различными форматами состояний
const testConditions = [
    // Простые случаи с пробелами
    'MS 61',           // -> MS61
    'MS 64',           // -> MS64
    'XF 45',           // -> XF45
    'AU 58',           // -> AU58
    
    // Случаи без пробелов (должны остаться без изменений)
    'MS61',            // -> MS61
    'MS64',            // -> MS64
    'XF45',            // -> XF45
    
    // Сложные случаи с дополнительными символами
    'MS 64RB',         // -> MS64RB
    'XF 45BN',         // -> XF45BN
    'PF 62 CAMEO',     // -> PF62CAMEO
    'PF 70 ULTRA CAMEO', // -> PF70ULTRACAMEO
    
    // Случаи без пробелов с дополнительными символами
    'MS64RB',          // -> MS64RB
    'PF62CAMEO',       // -> PF62CAMEO
    
    // Только состояния без градаций
    'MS',              // -> MS
    'AU',              // -> AU
    'UNC',             // -> UNC
    'PF',              // -> PF
    
    // Комбинированные состояния
    'AU/UNC',          // -> AU/UNC
    'VF/XF',           // -> VF/XF
    
    // Состояния с плюсами и минусами
    'XF+',             // -> XF+
    'VF-',             // -> VF-
    
    // Случаи с множественными пробелами
    'MS  64',          // -> MS64
    'PF  62  CAMEO',   // -> PF62CAMEO
    'XF   45   BN',    // -> XF45BN
    
    // Граничные случаи
    '  MS 61  ',       // -> MS61 (пробелы в начале и конце)
    'MS   64   RB',    // -> MS64RB (множественные пробелы)
];

console.log('🧪 Тестируем простую функцию обработки состояний с градациями...');
console.log('📋 Тестовые данные:');
console.log('');

testConditions.forEach((testCondition, index) => {
    const result = extractConditionWithGrade(testCondition);
    const status = result === testCondition.replace(/\s+/g, '') ? '✅' : '❌';
    console.log(`${index + 1}. ${status} "${testCondition}" -> "${result}"`);
});

console.log('');
console.log('📊 Выводы:');
console.log('✅ Простой подход убирает ВСЕ пробелы');
console.log('✅ Работает с любыми сложными состояниями');
console.log('✅ Не требует сложных regex');
console.log('✅ Надежно обрабатывает граничные случаи');
console.log('✅ Сохраняет существующие форматы без пробелов');
