$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'base64'
require 'cgi'
require 'excon'

require "heroku/connection"

require "heroku/vendor/heroku/okjson"

srand

module Heroku
  def self.new(options={})
    Connection.new(options)
  end
end
