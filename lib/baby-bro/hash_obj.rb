# frozen_string_literal: true
#
# HashObj
# v 2.0
# 08/31/2024
#
# Author: Bill Doughty
#
#
# Like Hashie::Mash but works like you want - ie. it doesn't dup value objects, it stores the originals
# Also works like HashWithIndifferentAccess

class HashObj < Hash
  def initialize(hash = nil)
    super()
    deep_update(hash) if hash
  end

  def [](key)
    return super(key) if key.is_a?(Numeric)
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
    return super(key) if key.is_a?(Numeric)
    if key?(key.to_s)
      return super(key.to_s)
    elsif key?(key.to_sym)
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
      if k.is_a?(Numeric)
        self[k] = v
      else
        send("#{k}=", v)
      end
    end
  end

end

if $PROGRAM_NAME == __FILE__
  obj = HashObj.new(id: -1)
  raise 'failure' unless obj.id == -1
  puts "Ruby version: #{RUBY_VERSION} (#{RUBY_PLATFORM})"
end
