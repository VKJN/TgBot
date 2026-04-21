# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv/load'
require_relative 'lib/http_checker'
require_relative 'lib/security_headers'
require_relative 'lib/history_store'

class HttpCheckerBot
  def initialize
    @history = HistoryStore.new
  end

  def run
    Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot|
      bot.listen do |message|
        text = message.text
        chat_id = message.chat.id

        case text
        when %r{^/check\s+(.+)}
          url = Regexp.last_match(1)
          handle_check(chat_id, bot, url)
        when %r{^/security\s+(.+)}
          url = Regexp.last_match(1)
          handle_security(chat_id, bot, url)
        when '/history'
          handle_history(chat_id, bot)
        when '/help', '/start'
          handle_help(chat_id, bot)
        else
          bot.api.send_message(chat_id: chat_id, text: '❓ Неизвестная команда. Введите /help')
        end
      end
    end
  end

  private

  def handle_check(chat_id, bot, url)
    # Сохраняем домен в историю
    domain = extract_domain(url)
    @history.add(domain) if domain

    result = HttpChecker.new(url).call
    text = format_check_result(result)
    bot.api.send_message(chat_id: chat_id, text: text, parse_mode: 'Markdown')
  rescue StandardError => e
    bot.api.send_message(chat_id: chat_id, text: "⚠️ Ошибка: #{e.message}")
  end

  def handle_security(chat_id, bot, url)
    result = SecurityHeaders.new(url).call
    text = format_security_result(result)
    bot.api.send_message(chat_id: chat_id, text: text, parse_mode: 'Markdown')
  rescue StandardError => e
    bot.api.send_message(chat_id: chat_id, text: "⚠️ Ошибка: #{e.message}")
  end

  def handle_history(chat_id, bot)
    domains = @history.last(3)
    text = if domains.empty?
             '📭 История пуста. Проверьте хотя бы один сайт через /check'
           else
             "📜 *Последние 3 проверенных домена:*\n" + domains.map.with_index(1) { |d, i| "#{i}. #{d}" }.join("\n")
           end
    bot.api.send_message(chat_id: chat_id, text: text, parse_mode: 'Markdown')
  end

  def handle_help(chat_id, bot)
    help_text = <<~HELP
      🤖 *HTTP Inspector Bot* – проверяет сайты на здоровье и безопасность.

      *Команды:*
      `/check <url>` – получить статус, веб-сервер и тип контента
      `/security <url>` – проверить заголовки безопасности
      `/history` – последние 3 проверенных домена
      `/help` – эта справка

      *Примеры:*
      `/check google.com`
      `/security https://example.com`
    HELP
    bot.api.send_message(chat_id: chat_id, text: help_text, parse_mode: 'Markdown')
  end

  def format_check_result(result)
    return "❌ Не удалось получить ответ: #{result[:error]}" if result[:error]

    status_emoji = result[:status].to_s.start_with?('2') ? '✅' : '⚠️'
    text = "#{status_emoji} *Результат проверки* `#{result[:url]}`\n"
    text += "• *Статус:* `#{result[:status]}` #{result[:status_text]}\n"
    text += "• *Сервер:* `#{result[:server] || 'не указан'}`\n"
    text += "• *Content-Type:* `#{result[:content_type] || 'не указан'}`"
    text
  end

  def format_security_result(result)
    return "❌ Ошибка: #{result[:error]}" if result[:error]

    text = "🔒 *Безопасность* `#{result[:url]}`\n"
    result[:headers].each do |header, present|
      icon = present ? '✅' : '❌'
      text += "#{icon} `#{header}`\n"
    end
    text += '⚠️ Не найдено ни одного стандартного заголовка безопасности.' unless result[:headers].values.any?
    text
  end

  def extract_domain(url)
    url.gsub(%r{^https?://}, '').split('/').first
  rescue StandardError
    url
  end
end

HttpCheckerBot.new.run if __FILE__ == $PROGRAM_NAME
