$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'base64'
require 'excon'

require "heroku-rb/connection"
require "heroku-rb/version"

require "heroku-rb/vendor/heroku/okjson"

module Heroku
  def self.new(options={})
    Connection.new(options)
  end
end
