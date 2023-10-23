require 'rails_helper'
require 'cache_manager'

RSpec.describe CacheManager do
  subject(:cache_manager) { CacheManager.new }
  let(:counter_key) { 'cache_hit_counter' }

  describe '#fetch' do
    let(:key) { 'test_key' }
    let(:test_data) { 'test_data' }

    it 'returns data from block and caches it' do
      data = cache_manager.fetch(key) { test_data }

      expect(data).to eq(test_data)
      expect(Rails.cache.read(key)).to eq(test_data)
    end

    it 'increments cache hit counter for cache hits' do
      Rails.cache.write(key, 'cached_data')
      cache_manager.fetch(key) { test_data }

      expect(Rails.cache.read(counter_key)).to eq(1)
    end

    it 'returns data from cache for cache hits' do
      Rails.cache.write(key, 'cached_data')
      data = cache_manager.fetch(key) { test_data }

      expect(data).to eq('cached_data')
    end
  end

  describe '#counter' do
    it 'returns 0 when cache hit counter is not set' do
      Rails.cache.delete(counter_key)

      expect(cache_manager.counter).to eq(0)
    end

    it 'returns cache hit count when cache hit counter is set' do
      Rails.cache.write(counter_key, 42)

      expect(cache_manager.counter).to eq(42)
    end
  end
end
