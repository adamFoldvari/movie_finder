class CacheManager
  COUNTER_KEY = 'cache_hit_counter'.freeze

  def fetch(key, options = {})
    if Rails.cache.exist?(key)
      count_cache_hit
      Rails.cache.read(key)
    else
      data = yield
      Rails.cache.write(key, data, options)
      data
    end
  end

  def counter
    @counter ||= Rails.cache.read(COUNTER_KEY) || 0
  end

  private

  def count_cache_hit
    @counter = counter + 1
    Rails.cache.write(COUNTER_KEY, @counter)
  end
end