# frozen_string_literal: true
#
# HashObj
# v 2.1.1
# 09/03/2024
#
# Author: Bill Doughty
#
# Like Hashie::Mash but works like you want - ie. it doesn't dup value objects, it stores the originals
# Also works like HashWithIndifferentAccess

class HashObj < Hash
  def initialize(hash = nil)
    super()
    deep_update(self.class.deep_copy(hash)) if hash
  end

  def [](key)
    return super(key) if !key.is_a?(String) && !key.is_a?(Symbol)
    if key?(key.to_s)
      return super(key.to_s)
    elsif key?(key.to_sym)
      return super(key.to_sym)
    end

    nil
  end

  def []=(key, value)
    key = key.to_sym if key.is_a?(String)
    super(key, value)
  end

  def delete(key)
    if key?(key.to_s)
      return super(key.to_s)
    elsif key?(key.to_sym)
      return super(key)
    else
      return super(key.to_sym)
    end

    nil
  end

  def id
    self[:id]
  end

  def to_yaml
    hash = Hash.new
    each do |k, v|
      hash[k.to_s] = v
    end
    hash.to_yaml
  end

  def method_missing(method, *args)
    method = method.to_s
    if (matches = method.match(/([\w-]*)=/))
      key = matches[1].to_sym
      return self[key] = args[0]
    else
      return self[method]
    end
  end

  private

  def deep_update(hash)
    hash.each do |k, v|
      v = self.class.new(v) if v.is_a?(Hash)
      if v.is_a?(Array)
        v.map! { |e| e.is_a?(Hash) ? self.class.new(e) : e }
      end
      if !k.is_a?(String) && !k.is_a?(Symbol)
        self[k] = v
      else
        send("#{k}=", v)
      end
    end
  end

  def self.deep_copy(hash)
    hash.each_with_object({}) do |(key, value), new_hash|
      new_hash[key] = value.is_a?(Hash) ? deep_copy(value) : value.dup rescue value
    end
  end
end

if $PROGRAM_NAME == __FILE__
  require 'date'
  puts "Ruby version: #{RUBY_VERSION} (#{RUBY_PLATFORM})"
  puts "Testing HashObj.."
  obj = HashObj.new(id: 1)
  raise 'failure' unless obj.id == 1
  obj = HashObj.new('id' => -1)
  raise 'failure' unless obj.id == -1
  obj = HashObj.new({1 => 2})
  raise 'failure' unless obj[1] == 2
  date = Date.new(2023,1,1)
  obj = HashObj.new(date => 'date')
  raise 'failure' unless obj[date] == 'date'
  obj = HashObj.new
  obj.one = 1
  raise 'failure' unless obj[:one] == 1
  raise 'failure' unless obj['one'] == 1
  obj = HashObj.new
  obj[:one] = 1
  raise 'failure' unless obj['one'] == 1
  obj = HashObj.new
  obj['one'] = 1
  raise 'failure' unless obj[:one] == 1
  obj = HashObj.new
  obj.one = 1
  raise 'failure' unless obj['one'] == 1
  raise 'failure' unless obj[:one] == 1
  h1 = {test: 1, test2: 2}
  h2 = {h1: [h1]}
  obj = HashObj.new(h2)
  raise "It shouldn't be a HashObj" if h2[:h1][0].is_a?(HashObj)
  puts "All tests passed"
end
