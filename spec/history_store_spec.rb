# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe HistoryStore do
  let(:store) { described_class.new }

  before do
    allow(File).to receive(:read).and_return('[]')
    allow(File).to receive(:write)
  end

  it 'сохраняет и возвращает последние домены' do
    store.add('google.com')
    store.add('github.com')
    store.add('stackoverflow.com')
    store.add('ruby-lang.org')

    expect(store.last(3)).to eq(['ruby-lang.org', 'stackoverflow.com', 'github.com'])
  end

  it 'не дублирует одинаковые домены подряд' do
    store.add('google.com')
    store.add('google.com')
    expect(store.all).to eq(['google.com'])
  end
end
