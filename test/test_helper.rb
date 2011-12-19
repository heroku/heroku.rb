require "#{File.dirname(__FILE__)}/../lib/heroku-rb"
require 'minitest/autorun'

def with_app(params={}, &block)
  begin
    data = @heroku.post_app(params).body
    name = data['name']
    yield(data)
  ensure
    @heroku.delete_app(name) rescue nil
  end
end
