require 'spec_helper'

RSpec.describe SecurityHeaders do
  let(:url) { 'example.com' }

  it 'проверяет наличие важных заголовков' do
    stub_request(:get, 'http://example.com')
      .to_return(headers: { 'X-Frame-Options' => 'DENY', 'X-Content-Type-Options' => 'nosniff' })

    result = described_class.new(url).call
    expect(result[:headers]['X-Frame-Options']).to be true
    expect(result[:headers]['X-Content-Type-Options']).to be true
    expect(result[:headers]['Strict-Transport-Security']).to be false
  end

  it 'обрабатывает ошибки соединения' do
    stub_request(:get, 'http://example.com').to_timeout
    result = described_class.new(url).call
    expect(result[:error]).to be_truthy
  end
end
