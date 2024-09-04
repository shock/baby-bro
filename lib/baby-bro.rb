$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$:.unshift(File.join(File.dirname(__FILE__), 'baby-bro')) unless $:.include?( $:.unshift(File.join(File.dirname(__FILE__), 'baby-bro')) )

module BabyBro
  def self.version
    File.read(File.join(File.dirname(__FILE__),'..','VERSION'))
  end
end

require 'extensions/integer'
require 'baby-bro/hash_obj'
require 'baby-bro/monitor'
require 'baby-bro/reporter'
require 'baby-bro/configurator'
