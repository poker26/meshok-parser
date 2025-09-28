const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
const config = require('./config');

const pool = new Pool(config.dbConfig);

// Функции для работы с прогрессом
function getProgressFilePath(auctionNumber) {
    return path.join(__dirname, `predictions_progress_${auctionNumber}.json`);
}

function saveProgress(auctionNumber, currentIndex, totalLots, processedCount, errorCount) {
    const progress = {
        auctionNumber,
        currentIndex,
        totalLots,
        processedCount,
        errorCount,
        lastUpdate: new Date().toISOString()
    };
    
    const filePath = getProgressFilePath(auctionNumber);
    fs.writeFileSync(filePath, JSON.stringify(progress, null, 2));
    console.log(`💾 Прогресс сохранен: ${currentIndex}/${totalLots} (обработано: ${processedCount}, ошибок: ${errorCount})`);
}

function loadProgress(auctionNumber) {
    const filePath = getProgressFilePath(auctionNumber);
    
    if (!fs.existsSync(filePath)) {
        return null;
    }
    
    try {
        const data = fs.readFileSync(filePath, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        console.error('Ошибка загрузки прогресса:', error);
        return null;
    }
}

function clearProgress(auctionNumber) {
    const filePath = getProgressFilePath(auctionNumber);
    
    if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
        console.log('🗑️ Файл прогресса удален');
    }
}

// Импортируем класс генератора прогнозов
const ImprovedPredictionsGenerator = require('./improved-predictions-generator');

// Функция для генерации прогнозов с прогрессом
async function generatePredictionsWithProgress(auctionNumber, startFromIndex = null) {
    console.log(`🔮 Генерация прогнозов для аукциона ${auctionNumber}...`);
    
    // Загружаем прогресс если не указан стартовый индекс
    let progress = null;
    if (startFromIndex === null) {
        progress = loadProgress(auctionNumber);
        if (progress) {
            startFromIndex = progress.currentIndex;
            console.log(`📂 Возобновляем с позиции: ${startFromIndex}`);
        }
    }

    const generator = new ImprovedPredictionsGenerator();
    
    try {
        await generator.init();
        
        // Получаем все лоты аукциона
        const lotsResult = await pool.query(`
            SELECT id, lot_number, condition, metal, weight, year, letters, winning_bid, coin_description, auction_number
            FROM auction_lots 
            WHERE auction_number = $1
            ORDER BY lot_number
        `, [auctionNumber]);
        
        const lots = lotsResult.rows;
        console.log(`📋 Найдено ${lots.length} лотов для прогнозирования`);
        
        if (lots.length === 0) {
            console.log('❌ Лоты не найдены');
            return;
        }
        
        const startIndex = startFromIndex || 0;
        const totalLots = lots.length;
        let processedCount = 0;
        let errorCount = 0;
        
        console.log(`🎯 Начинаем с индекса: ${startIndex}`);
        
        // Обрабатываем лоты с сохранением прогресса
        for (let i = startIndex; i < totalLots; i++) {
            const lot = lots[i];
            console.log(`🔄 Обрабатываем лот ${i + 1}/${totalLots}: ${lot.lot_number}`);
            
            try {
                const prediction = await generator.predictPrice(lot);
                
                // Сохраняем прогноз в базу данных
                await pool.query(`
                    INSERT INTO lot_price_predictions (lot_id, predicted_price, metal_value, numismatic_premium, confidence_score, prediction_method, sample_size)
                    VALUES ($1, $2, $3, $4, $5, $6, $7)
                    ON CONFLICT (lot_id) DO UPDATE SET
                        predicted_price = EXCLUDED.predicted_price,
                        metal_value = EXCLUDED.metal_value,
                        numismatic_premium = EXCLUDED.numismatic_premium,
                        confidence_score = EXCLUDED.confidence_score,
                        prediction_method = EXCLUDED.prediction_method,
                        sample_size = EXCLUDED.sample_size,
                        created_at = NOW();
                `, [
                    prediction.lot_id,
                    prediction.predicted_price,
                    prediction.metal_value,
                    prediction.numismatic_premium,
                    prediction.confidence_score,
                    prediction.prediction_method,
                    prediction.sample_size
                ]);
                
                processedCount++;
                console.log(`✅ Лот ${lot.lot_number}: прогноз ${prediction.predicted_price || 'не сгенерирован'}`);
                
            } catch (error) {
                errorCount++;
                console.error(`❌ Ошибка прогнозирования для лота ${lot.lot_number}:`, error.message);
            }
            
            // Сохраняем прогресс каждые 10 лотов
            if ((i + 1) % 10 === 0 || i === totalLots - 1) {
                saveProgress(auctionNumber, i + 1, totalLots, processedCount, errorCount);
            }
            
            // Небольшая задержка между лотами
            await new Promise(resolve => setTimeout(resolve, 100));
        }
        
        console.log(`🎉 Генерация прогнозов завершена!`);
        console.log(`📊 Обработано: ${processedCount}, Ошибок: ${errorCount}`);
        
        // Очищаем прогресс при успешном завершении
        clearProgress(auctionNumber);
        
    } catch (error) {
        console.error('❌ Критическая ошибка генерации прогнозов:', error);
    } finally {
        await generator.close();
    }
}

// Основная функция
async function main() {
    console.log('🚀 Запуск генерации прогнозов с сохранением прогресса...');

    try {
        // Проверяем аргументы командной строки
        const args = process.argv.slice(2);
        let auctionNumber, startFromIndex = null;
        
        if (args.length > 0) {
            auctionNumber = parseInt(args[0]);
            if (isNaN(auctionNumber)) {
                console.log('❌ Неверный номер аукциона. Используйте: node generate-predictions-with-progress.js [номер_аукциона] [стартовый_индекс]');
                return;
            }
            
            // Проверяем, есть ли второй аргумент (стартовый индекс)
            if (args.length > 1) {
                startFromIndex = parseInt(args[1]);
                if (isNaN(startFromIndex)) {
                    console.log('❌ Неверный стартовый индекс. Используйте число');
                    return;
                }
                console.log(`🎯 Запуск с индекса: ${startFromIndex}`);
            }
        } else {
            console.log('❌ Не указан номер аукциона');
            console.log('💡 Используйте: node generate-predictions-with-progress.js [номер_аукциона] [стартовый_индекс]');
            return;
        }
        
        // Генерируем прогнозы
        await generatePredictionsWithProgress(auctionNumber, startFromIndex);
        
        console.log('✅ Генерация прогнозов завершена');
        
    } catch (error) {
        console.error('❌ Критическая ошибка:', error);
    } finally {
        await pool.end();
    }
}

// Запуск скрипта
if (require.main === module) {
    main();
}

module.exports = {
    generatePredictionsWithProgress,
    getProgressFilePath,
    loadProgress,
    clearProgress
};
