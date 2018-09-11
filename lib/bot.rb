require 'digest'
require 'redis'

class Bot
  DEPTH = 10
  TERMINATOR = Digest::SHA256.base64digest('')[0..3]

  def initialize(redis_url = 'redis://localhost:6379')
    @redis = Redis.new(url: redis_url)
  end

  def learn(text)
    keys = [TERMINATOR]
    string_to_hash_chain(text).each do |hash|
      depth = [keys.length, DEPTH].min.to_i
      depth.times do |i|
        key = Digest::SHA256.base64digest(keys.last(i + 1).join)[0..3]
        @redis.zincrby(key, (depth - i), hash)
      end
      keys.push(hash)
    end
    @redis.zincrby(keys.last, 1, TERMINATOR)
  end

  def speak
    chain = [TERMINATOR]
    loop do
      keys = []
      [chain.length, DEPTH].min.times do |i|
        key = Digest::SHA256.base64digest(chain.last(i + 1).join)[0..3]
        @redis.zrange(key, 0, -1).each do |hash|
          @redis.zscore(key, hash).to_i.times do
            keys.push(hash)
          end
        end
      end
      hash = keys.sample
      break if hash === TERMINATOR
      break if hash_chain_to_string(chain + [hash]).length > 280
      chain.push(hash)
    end
    hash_chain_to_string(chain)
  end

  def reset
    @redis.flushall
  end

  private

  def string_to_hash_chain(string)
    string.scan(/[^\s]+/).map { |word|
      key = Digest::SHA256.base64digest(word)[0..3]
      @redis.set("w_#{key}", word)
      key
    }
  end

  def hash_chain_to_string(chain)
    chain.reject { |key|
      key === TERMINATOR
    }.map { |key|
      @redis.get("w_#{key}")
    }.join(' ')
  end
end
