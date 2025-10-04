#!/usr/bin/env python3

import sys
import os
import time
import json
from datetime import datetime
import urllib.request
import urllib.parse
from urllib.error import URLError, HTTPError

def fetch_with_simple_requests(category_id='252', finished=True):
    print('🌐 Using simple urllib for Cloudflare bypass...')
    
    url = f"https://meshok.net/good/{category_id}{'?opt=2' if finished else ''}"
    print(f"📄 Fetching: {url}")
    
    try:
        # Создаем запрос с реалистичными заголовками
        req = urllib.request.Request(
            url,
            headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.9',
                'Accept-Encoding': 'gzip, deflate, br',
                'Cache-Control': 'no-cache',
                'Pragma': 'no-cache',
                'Sec-Fetch-Dest': 'document',
                'Sec-Fetch-Mode': 'navigate',
                'Sec-Fetch-Site': 'none',
                'Sec-Fetch-User': '?1',
                'Upgrade-Insecure-Requests': '1',
                'DNT': '1'
            }
        )
        
        print('⏳ Making request with urllib...')
        
        with urllib.request.urlopen(req, timeout=30) as response:
            content = response.read().decode('utf-8')
            
            print(f'📊 Status code: {response.status}')
            print(f'📊 Response size: {len(content) / 1024:.2f} KB')
            
            # Проверяем на Cloudflare
            if 'Just a moment' in content or 'Один момент' in content:
                print('⚠️  Cloudflare challenge detected')
            else:
                print('✅ No Cloudflare challenge detected')
            
            # Сохраняем результат
            timestamp = datetime.now().strftime('%Y-%m-%dT%H-%M-%S-%fZ')
            filename = f"simple_requests_good{category_id}_opt{'2' if finished else '1'}_{timestamp}.html"
            filepath = os.path.join('data', filename)
            
            os.makedirs('data', exist_ok=True)
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f'✅ Saved to: {filename}')
            
            # Простой анализ содержимого
            if '<title>' in content:
                title_start = content.find('<title>') + 7
                title_end = content.find('</title>')
                if title_end > title_start:
                    title = content[title_start:title_end]
                    print(f'📋 Page title: {title}')
            
            # Поиск ссылок на лоты
            item_links = content.count('href="/item/')
            print(f'🔗 Item links found: {item_links}')
            
            if item_links > 0:
                print('🎉 Successfully obtained auction data with simple requests!')
                
                # Извлекаем первые несколько ссылок
                import re
                link_matches = re.findall(r'href="(/item/[^"]*)"', content)
                print('📋 First 5 item links:')
                for i, link in enumerate(link_matches[:5]):
                    print(f'   {i + 1}. https://meshok.net{link}')
            else:
                print('⚠️  No auction links found')
            
            # Поиск цен
            price_matches = re.findall(r'[0-9,]+[ ]*₽|[0-9,]+[ ]*руб', content)
            if price_matches:
                print(f'💰 Prices found: {len(price_matches)}')
                print('📋 Sample prices:')
                for i, price in enumerate(price_matches[:3]):
                    print(f'   {i + 1}. {price}')
            
            # Поиск таблиц
            table_count = content.count('<table')
            print(f'📊 Tables found: {table_count}')
            
            # Поиск форм
            form_count = content.count('<form')
            print(f'📝 Forms found: {form_count}')
            
            # Поиск JSON данных
            json_matches = re.findall(r'\{[^{}]*"[^"]*"[^{}]*\}', content)
            if json_matches:
                print(f'📜 JSON data found: {len(json_matches)} matches')
                print('📋 Sample JSON:')
                for i, json_data in enumerate(json_matches[:2]):
                    print(f'   {i + 1}. {json_data[:100]}...')
            else:
                print('📜 No JSON data found')
        
    except HTTPError as e:
        print(f'❌ HTTP Error: {e.code} - {e.reason}')
    except URLError as e:
        print(f'❌ URL Error: {e.reason}')
    except Exception as e:
        print(f'❌ Error: {e}')

if __name__ == '__main__':
    category_id = sys.argv[1] if len(sys.argv) > 1 else '252'
    finished = sys.argv[2] != 'false' if len(sys.argv) > 2 else True
    fetch_with_simple_requests(category_id, finished)
