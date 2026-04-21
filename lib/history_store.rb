require 'json'
require 'fileutils'

class HistoryStore
  DATA_DIR = File.join(__dir__, '..', 'data')
  HISTORY_FILE = File.join(DATA_DIR, 'history.json')

  def initialize
    FileUtils.mkdir_p(DATA_DIR)
    @history = load_history
  end

  def add(domain)
    @history.unshift(domain)
    @history = @history.uniq.first(10)
    save_history
  end

  def last(limit = 3)
    @history.first(limit)
  end

  def all
    @history.dup
  end

  private

  def load_history
    return [] unless File.exist?(HISTORY_FILE)

    JSON.parse(File.read(HISTORY_FILE))
  rescue StandardError
    []
  end

  def save_history
    File.write(HISTORY_FILE, JSON.pretty_generate(@history))
  end
end
