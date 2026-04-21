require 'spec_helper'
require 'telegram/bot'
require 'webmock/rspec'

RSpec.describe 'Bot integration' do
  it 'мокает /check команду через WebMock' do
    stub_request(:get, 'http://google.com')
      .to_return(status: 200, headers: { 'Server' => 'gws', 'Content-Type' => 'text/html' })

    result = HttpChecker.new('google.com').call
    expect(result[:status]).to eq(200)
    expect(result[:server]).to eq('gws')
  end
end
