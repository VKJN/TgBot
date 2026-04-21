# frozen_string_literal: true

require 'faraday'
require 'uri'

class HttpChecker
  def initialize(url)
    @url = normalize_url(url)
  end

  def call
    response = Faraday.get(@url) do |req|
      req.options.timeout = 5
      req.options.open_timeout = 3
    end

    {
      url: @url,
      status: response.status,
      status_text: status_text(response.status),
      server: response.headers['server'],
      content_type: response.headers['content-type'],
      error: nil
    }
  rescue Faraday::Error => e
    {
      url: @url,
      error: "Соединение не удалось: #{e.message}"
    }
  end

  private

  def normalize_url(url)
    return url if url.start_with?('http://', 'https://')

    "http://#{url}"
  end

  def status_text(code)
    case code
    when 200 then 'OK'
    when 404 then 'Not Found'
    when 403 then 'Forbidden'
    when 500 then 'Internal Server Error'
    else 'Unknown'
    end
  end
end
