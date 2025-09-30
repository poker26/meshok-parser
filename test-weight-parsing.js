const CatalogParser = require('./catalog-parser.js');

// Создаем экземпляр парсера для тестирования
const parser = new CatalogParser();

// Тестовые описания
const testDescriptions = [
    "Au 156,41", // Случай 1: вес без единиц
    "Au`917, нормативный вес - 0,80 гр", // Случай 2: проба и нормативный вес
    "Au 917, вес 0,80 гр", // Случай 3: проба и вес с единицами
    "Au 917, 0,80 гр", // Случай 4: проба и вес
    "Au 917, 0,80 гр, чистого золота - 0,73 гр", // Случай 5: с указанием чистого металла
    "Ag 925, 15,5 гр", // Серебро
    "Pt 999, 1,0 гр", // Платина
    "Обычное описание без веса" // Описание без веса
];

console.log('🧪 Тестирование парсинга веса и пробы...\n');

testDescriptions.forEach((description, index) => {
    console.log(`--- Тест ${index + 1} ---`);
    console.log(`Описание: "${description}"`);
    
    const result = parser.parseLotDescription(description);
    
    console.log('Результат:');
    console.log(`  Металл: ${result.metal || 'не найден'}`);
    console.log(`  Вес монеты: ${result.coin_weight || 'не найден'}г`);
    console.log(`  Проба: ${result.fineness || 'не найдена'}`);
    console.log(`  Чистый металл: ${result.pure_metal_weight || 'не найден'}г`);
    console.log(`  Вес в унциях: ${result.weight_oz || 'не найден'}oz`);
    console.log('');
});

console.log('✅ Тестирование завершено!');


