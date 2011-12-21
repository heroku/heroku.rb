require 'heroku/api/apps'
require 'heroku/api/config_vars'
require 'heroku/mock'
require 'heroku/stubs/apps'
require 'heroku/stubs/config_vars'
require "heroku/version"

module Heroku
  class API < Excon::Connection

    def initialize(options={})
      @api_key = options.delete(:heroku_api_key) || ENV['HEROKU_API_KEY']
      user_pass = ":#{@api_key}"
      options = {
        :headers  => {},
        :host     => 'api.heroku.com',
        :scheme   => 'https'
      }.merge(options)
      options[:headers] = {
        'Accept'                => 'application/json',
        'Authorization'         => "Basic #{Base64.encode64(user_pass).gsub("\n", '')}",
        'User-Agent'            => "heroku-rb/#{Heroku::VERSION}",
        'X-Heroku-API-Version'  => '3',
        'X-Ruby-Version'        => RUBY_VERSION,
        'X-Ruby-Platform'       => RUBY_PLATFORM
      }.merge(options[:headers])
      super("#{options[:scheme]}://#{options[:host]}", options)
    end

    def request(params, &block)
      if params[:body]
        params[:body] = format_body(params[:body])
      end
      response = super
      if response.body && !response.body.empty?
        begin
          response.body = Heroku::OkJson.decode(response.body)
        rescue
          # leave non-JSON body as is
        end
      end
      response
    end

    private

    # takes { 'type' => { 'key' => 'value, ... } }
    # and returns "type[key]=value&..."
    def format_body(body)
      case body
      when Hash
        formatted_body = ''
        body.each do |type, data|
          data.each do |key, value|
            formatted_body << "#{type}[#{key}]=#{value}&"
          end
        end
        formatted_body.chop!
      when String
        body
      else
        raise("Can not format body '#{body.inspect}'.")
      end
    end

  end
end
