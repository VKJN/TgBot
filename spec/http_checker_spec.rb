# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HttpChecker do
  describe '#call' do
    let(:url) { 'example.com' }

    context 'когда сайт отвечает 200' do
      before do
        stub_request(:get, 'http://example.com')
          .to_return(status: 200, headers: { 'Server' => 'nginx', 'Content-Type' => 'text/html' })
      end

      it 'возвращает статус 200 и заголовки' do
        result = described_class.new(url).call
        expect(result[:status]).to eq(200)
        expect(result[:server]).to eq('nginx')
        expect(result[:content_type]).to eq('text/html')
        expect(result[:error]).to be_nil
      end
    end

    context 'когда сайт возвращает 404' do
      before do
        stub_request(:get, 'http://example.com').to_return(status: 404)
      end

      it 'возвращает статус 404' do
        result = described_class.new(url).call
        expect(result[:status]).to eq(404)
        expect(result[:status_text]).to eq('Not Found')
      end
    end

    context 'когда соединение не удалось' do
      before do
        stub_request(:get, 'http://example.com').to_timeout
      end

      it 'возвращает ошибку' do
        result = described_class.new(url).call
        expect(result[:error]).to include('Соединение не удалось')
      end
    end
  end
end
