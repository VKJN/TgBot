# HTTP Inspector Bot

Telegram-бот для проверки HTTP-статусов, заголовков безопасности и истории проверок.

## Установка

1. `bundle install`
2. Скопируй `.env.example` в `.env` и вставь токен бота от @BotFather
3. Запусти: `ruby bot.rb`

## Команды

- `/check <url>` – статус, сервер, content-type
- `/security <url>` – проверка security-заголовков
- `/history` – последние 3 домена (персистентность через JSON)
- `/help` – справка

## Тесты

`bundle exec rspec`

## CI

GitHub Actions запускает Rubocop и RSpec.