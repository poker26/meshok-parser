const CatalogParser = require('./catalog-parser.js');

async function test50RublesParsing() {
    const parser = new CatalogParser();
    
    try {
        await parser.init();
        
        // Тестовые описания монет "50 рублей" с весом
        const testDescriptions = [
            "50 рублей. Софийский собор в Новгороде 1988г. ММД. Au 7,78. | Тираж: 25 000. 900 проба. Диаметр 22,6 мм.",
            "150 рублей. Слово о полку Игореве 1988г. ЛМД. Pt 15,55. | В слабе NGC. Выдающийся памятник древнерусской литературы рассказывает о неудачном походе новгород-северского князя Игоря Святославича против половцев в 1185 году.",
            "50 рублей. Успенский собор в Москве 1989г. ММД. Au 7,78. | Тираж: 25 000. 900 проба. Диаметр 22,6 мм."
        ];
        
        console.log('🧪 Тестирование парсинга монет "50 рублей"...\n');
        
        testDescriptions.forEach((description, index) => {
            console.log(`--- Тест ${index + 1} ---`);
            console.log(`📝 Описание: ${description.substring(0, 80)}...\n`);
            
            const result = parser.parseLotDescription(description);
            
            console.log('📋 Результат парсинга:');
            console.log(`  - Металл: ${result.metal || 'не найден'}`);
            console.log(`  - Вес монеты: ${result.coin_weight || 'не найден'}г`);
            console.log(`  - Проба: ${result.fineness || 'не найдена'}`);
            console.log(`  - Чистый металл: ${result.pure_metal_weight || 'не найден'}г`);
            console.log(`  - Вес в унциях: ${result.weight_oz || 'не найден'}oz`);
            console.log('');
        });
        
        console.log('✅ Тестирование завершено!');
        
    } catch (error) {
        console.error('❌ Ошибка при тестировании:', error);
    } finally {
        await parser.close();
    }
}

test50RublesParsing();






