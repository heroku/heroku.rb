require "#{File.dirname(__FILE__)}/../lib/heroku/api"

require 'rubygems'
gem 'minitest' # ensure we are using the gem version
require 'minitest/autorun'
require 'time'

def heroku
  Heroku.new(:api_key => 'API_KEY', :mock => true)
end

def random_name
  "heroku-rb-#{SecureRandom.hex(10)}"
end

def random_email_address
  "email@#{random_name}.com"
end

def with_app(params={}, &block)
  begin
    data = heroku.post_app(params).body
    @name = data['name']
    yield(data)
  ensure
    heroku.delete_app(@name) rescue nil
  end
end
