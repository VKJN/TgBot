require 'faraday'

class SecurityHeaders
  IMPORTANT_HEADERS = %w[
    X-Frame-Options
    X-Content-Type-Options
    X-XSS-Protection
    Strict-Transport-Security
    Content-Security-Policy
  ].freeze

  def initialize(url)
    @url = normalize_url(url)
  end

  def call
    response = Faraday.get(@url) do |req|
      req.options.timeout = 5
    end

    headers = response.headers
    result = {}
    IMPORTANT_HEADERS.each do |header|
      result[header] = !headers[header].nil?
    end

    {
      url: @url,
      headers: result,
      error: nil
    }
  rescue Faraday::Error => e
    {
      url: @url,
      headers: {},
      error: e.message
    }
  end

  private

  def normalize_url(url)
    return url if url.start_with?('http://', 'https://')

    "http://#{url}"
  end
end
