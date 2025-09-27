const { main } = require('./update-current-auction');
const cron = require('node-cron');

console.log('🔄 Запуск автоматического обновления ставок...');

// Обновляем каждые 5 минут
cron.schedule('*/5 * * * *', async () => {
    console.log(`\n⏰ ${new Date().toLocaleString('ru-RU')} - Обновление ставок...`);
    try {
        await main();
    } catch (error) {
        console.error('❌ Ошибка автоматического обновления:', error);
    }
});

// Обновляем сразу при запуске
main().catch(console.error);

console.log('✅ Автоматическое обновление запущено (каждые 5 минут)');
console.log('Нажмите Ctrl+C для остановки');
