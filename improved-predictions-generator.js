const { Client } = require('pg');
const config = require('./config');

class ImprovedPredictionsGenerator {
    constructor() {
        this.dbClient = null;
        this.preciousMetalPrices = {
            'Au': 7500, // Золото за грамм
            'Ag': 100,  // Серебро за грамм
            'Pt': 3000, // Платина за грамм
            'Pd': 2000  // Палладий за грамм
        };
        this.metalPurities = {
            'Au': 0.9,  // 90% для золотых монет
            'Ag': 0.9,  // 90% для серебряных монет
            'Pt': 0.95, // 95% для платиновых монет
            'Pd': 0.95  // 95% для палладиевых монет
        };
    }

    async init() {
        this.dbClient = new Client(config.dbConfig);
        await this.dbClient.connect();
        console.log('🔗 Подключение к базе данных установлено');
    }

    async close() {
        if (this.dbClient) {
            await this.dbClient.end();
            console.log('🧹 Ресурсы освобождены');
        }
    }

    // Поиск аналогичных лотов
    async findSimilarLots(lot) {
        const { condition, metal, year, letters, coin_description } = lot;
        
        // Извлекаем номинал из описания монеты
        const denominationMatch = coin_description.match(/(\d+)\s*рублей?/i);
        const currentDenomination = denominationMatch ? denominationMatch[1] : null;
        
        // Ищем лоты с точно такими же параметрами + номинал
        let query = `
            SELECT 
                id,
                lot_number,
                auction_number,
                winning_bid,
                weight,
                coin_description,
                auction_end_date
            FROM auction_lots 
            WHERE condition = $1 
                AND metal = $2 
                AND year = $3 
                AND letters = $4
                AND winning_bid IS NOT NULL 
                AND winning_bid > 0
                AND id != $5
        `;
        
        const params = [condition, metal, year, letters, lot.id];
        
        // Если номинал найден, добавляем его в условие поиска
        if (currentDenomination) {
            // Используем более точное сопоставление с границами слов
            query += ` AND coin_description ~ $${params.length + 1}`;
            params.push(`\\m${currentDenomination}\\s*рублей?\\M`);
        }
        
        query += ` ORDER BY auction_end_date DESC`;
        
        const result = await this.dbClient.query(query, params);
        
        return result.rows;
    }

    // Расчет стоимости металла на текущую дату
    calculateMetalValue(metal, weight) {
        if (!weight || weight <= 0 || !this.preciousMetalPrices[metal]) {
            return 0;
        }
        const pricePerGram = this.preciousMetalPrices[metal];
        const purity = this.metalPurities[metal] || 1;
        return pricePerGram * weight * purity;
    }

    // Основная функция прогнозирования
    async predictPrice(lot) {
        const similarLots = await this.findSimilarLots(lot);
        
        console.log(`🔍 Лот ${lot.lot_number}: найдено ${similarLots.length} аналогичных лотов`);
        
        // Случай 1: Аналогичные лоты не найдены
        if (similarLots.length === 0) {
            console.log(`   ❌ Аналоги не найдены - прогноз не генерируется`);
            return {
                predicted_price: null,
                metal_value: this.calculateMetalValue(lot.metal, lot.weight),
                numismatic_premium: null,
                confidence_score: 0,
                prediction_method: 'no_similar_lots',
                sample_size: 0
            };
        }
        
        // Случай 2: Найден только один аналогичный лот
        if (similarLots.length === 1) {
            const similarLot = similarLots[0];
            const currentMetalValue = this.calculateMetalValue(lot.metal, lot.weight);
            const similarMetalValue = this.calculateMetalValue(similarLot.metal, similarLot.weight);
            
            // Корректируем цену на разницу в стоимости металла
            let predictedPrice = similarLot.winning_bid;
            if (currentMetalValue > 0 && similarMetalValue > 0) {
                const metalValueDifference = currentMetalValue - similarMetalValue;
                predictedPrice = similarLot.winning_bid + metalValueDifference;
                
                // Проверяем на NaN и исправляем
                if (isNaN(predictedPrice) || !isFinite(predictedPrice)) {
                    predictedPrice = similarLot.winning_bid; // Используем цену аналога без корректировки
                    console.log(`   ⚠️ Корректировка металла привела к NaN, используем цену аналога: ${similarLot.winning_bid}`);
                } else {
                    console.log(`   📊 Один аналог: ${similarLot.winning_bid} → ${predictedPrice} (корректировка металла: ${metalValueDifference.toFixed(0)})`);
                }
            } else {
                console.log(`   📊 Один аналог: ${similarLot.winning_bid} → ${predictedPrice} (без корректировки металла)`);
            }
            
            return {
                predicted_price: Math.round(predictedPrice),
                metal_value: currentMetalValue,
                numismatic_premium: Math.round(predictedPrice - currentMetalValue),
                confidence_score: 0.6, // Средняя уверенность для одного аналога
                prediction_method: 'single_similar_lot',
                sample_size: 1
            };
        }
        
        // Случай 3: Найдено два и более аналогичных лотов
        console.log(`   📈 Множественные аналоги (${similarLots.length}) - применяем статистическую модель`);
        
        // Рассчитываем статистики
        const prices = similarLots.map(lot => lot.winning_bid);
        const mean = prices.reduce((sum, price) => sum + price, 0) / prices.length;
        const median = prices.sort((a, b) => a - b)[Math.floor(prices.length / 2)];
        
        // Используем медиану как более устойчивую к выбросам
        let predictedPrice = median;
        
        // Корректировка на стоимость металла для драгоценных металлов
        if (this.preciousMetalPrices[lot.metal] && lot.weight) {
            const currentMetalValue = this.calculateMetalValue(lot.metal, lot.weight);
            
            // Рассчитываем среднюю стоимость металла для аналогичных лотов
            const avgSimilarMetalValue = similarLots.reduce((sum, similarLot) => {
                return sum + this.calculateMetalValue(similarLot.metal, similarLot.weight);
            }, 0) / similarLots.length;
            
            // Корректируем прогноз на разницу в стоимости металла
            const metalValueDifference = currentMetalValue - avgSimilarMetalValue;
            predictedPrice = median + metalValueDifference;
            
            // Проверяем на NaN и исправляем
            if (isNaN(predictedPrice) || !isFinite(predictedPrice)) {
                predictedPrice = median; // Используем медиану без корректировки
                console.log(`   ⚠️ Корректировка металла привела к NaN, используем медиану: ${median}`);
            } else {
                console.log(`   🔧 Корректировка металла: ${metalValueDifference.toFixed(0)}`);
            }
        }
        
        // Рассчитываем уверенность на основе размера выборки и разброса цен
        const variance = prices.reduce((sum, price) => sum + Math.pow(price - mean, 2), 0) / prices.length;
        const coefficientOfVariation = Math.sqrt(variance) / mean;
        
        let confidence = Math.min(0.95, 0.5 + (similarLots.length / 20)); // Базовая уверенность
        if (coefficientOfVariation > 0.5) {
            confidence *= 0.8; // Снижаем уверенность при большом разбросе
        }
        
        console.log(`   📊 Медиана: ${median}, Корректированная: ${predictedPrice}, Уверенность: ${(confidence * 100).toFixed(1)}%`);
        
        return {
            predicted_price: Math.round(predictedPrice),
            metal_value: this.calculateMetalValue(lot.metal, lot.weight),
            numismatic_premium: Math.round(predictedPrice - this.calculateMetalValue(lot.metal, lot.weight)),
            confidence_score: confidence,
            prediction_method: 'statistical_model',
            sample_size: similarLots.length
        };
    }

    // Генерация прогнозов для аукциона
    async generatePredictionsForAuction(auctionNumber) {
        console.log(`\n🏆 Генерируем улучшенные прогнозы для аукциона ${auctionNumber}:`);
        
        // Получаем все лоты аукциона
        const lotsResult = await this.dbClient.query(`
            SELECT id, lot_number, condition, metal, weight, year, letters, winning_bid, coin_description
            FROM auction_lots 
            WHERE auction_number = $1
            ORDER BY lot_number
        `, [auctionNumber]);
        
        const lots = lotsResult.rows;
        console.log(`📋 Найдено ${lots.length} лотов для прогнозирования`);
        
        const predictions = [];
        let processedCount = 0;
        
        for (const lot of lots) {
            try {
                const prediction = await this.predictPrice(lot);
                predictions.push({
                    lot_id: lot.id,
                    ...prediction
                });
                
                processedCount++;
                if (processedCount % 10 === 0) {
                    console.log(`   ⏳ Обработано ${processedCount}/${lots.length} лотов`);
                }
            } catch (error) {
                console.error(`❌ Ошибка прогнозирования для лота ${lot.lot_number}:`, error.message);
            }
        }
        
        console.log(`\n💾 Сохранение ${predictions.length} прогнозов в базу данных...`);
        
        // Сохраняем прогнозы
        for (const prediction of predictions) {
            try {
                await this.dbClient.query(`
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
            } catch (error) {
                console.error(`❌ Ошибка сохранения прогноза для лота ${prediction.lot_id}:`, error.message);
            }
        }
        
        // Статистика
        const withPredictions = predictions.filter(p => p.predicted_price !== null).length;
        const withoutPredictions = predictions.filter(p => p.predicted_price === null).length;
        
        console.log(`✅ Сохранено ${predictions.length} прогнозов для аукциона ${auctionNumber}`);
        console.log(`   📊 С прогнозами: ${withPredictions}, Без прогнозов: ${withoutPredictions}`);
    }

    // Основная функция
    async generatePredictions() {
        console.log('🔮 ГЕНЕРАЦИЯ УЛУЧШЕННЫХ ПРОГНОЗОВ');
        
        // Получаем только текущий (самый новый) аукцион
        const currentAuction = await this.dbClient.query(`
            SELECT DISTINCT auction_number
            FROM auction_lots
            ORDER BY auction_number DESC
            LIMIT 1
        `);
        
        if (currentAuction.rows.length === 0) {
            console.log('❌ Активных аукционов не найдено');
            return;
        }
        
        const auctionNumber = currentAuction.rows[0].auction_number;
        console.log(`📊 Генерируем прогнозы только для текущего аукциона ${auctionNumber}`);
        
        await this.generatePredictionsForAuction(auctionNumber);
        
        console.log('\n🎉 Генерация улучшенных прогнозов завершена!');
    }
}

// Запуск
async function main() {
    const generator = new ImprovedPredictionsGenerator();
    try {
        await generator.init();
        
        // Проверяем аргументы командной строки
        const args = process.argv.slice(2);
        if (args.length > 0) {
            const auctionNumber = args[0];
            console.log(`🎯 Генерируем прогнозы для указанного аукциона ${auctionNumber}`);
            await generator.generatePredictionsForAuction(auctionNumber);
        } else {
            await generator.generatePredictions();
        }
    } catch (error) {
        console.error('❌ Ошибка генерации прогнозов:', error);
    } finally {
        await generator.close();
    }
}

if (require.main === module) {
    main();
}

module.exports = ImprovedPredictionsGenerator;
