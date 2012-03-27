require "base64"
require "cgi"
require "excon"
require "securerandom"
require "stringio"
require "zlib"

__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__), ".."))
unless $LOAD_PATH.include?(__LIB_DIR__)
  $LOAD_PATH.unshift(__LIB_DIR__)
end

require "heroku/api/vendor/okjson"

require "heroku/api/errors"
require "heroku/api/mock"
require "heroku/api/version"

require "heroku/api/addons"
require "heroku/api/apps"
require "heroku/api/collaborators"
require "heroku/api/config_vars"
require "heroku/api/domains"
require "heroku/api/keys"
require "heroku/api/logs"
require "heroku/api/processes"
require "heroku/api/releases"
require "heroku/api/stacks"
require "heroku/api/user"

srand

module Heroku
  class API

    def initialize(options={})
      @api_key = options.delete(:api_key) || ENV['HEROKU_API_KEY']
      user_pass = ":#{@api_key}"
      options = {
        :headers  => {},
        :host     => 'api.heroku.com',
        :scheme   => 'https'
      }.merge(options)
      options[:headers] = {
        'Accept'                => 'application/json',
        'Accept-Encoding'       => 'gzip',
        #'Accept-Language'       => 'en-US, en;q=0.8',
        'Authorization'         => "Basic #{Base64.encode64(user_pass).gsub("\n", '')}",
        'User-Agent'            => "heroku-rb/#{Heroku::API::VERSION}",
        'X-Heroku-API-Version'  => '3',
        'X-Ruby-Version'        => RUBY_VERSION,
        'X-Ruby-Platform'       => RUBY_PLATFORM
      }.merge(options[:headers])
      @connection = Excon.new("#{options[:scheme]}://#{options[:host]}", options)
    end

    def request(params, &block)
      begin
        response = @connection.request(params, &block)
      rescue Excon::Errors::NotFound => error
        reerror = Heroku::API::Errors::NotFound.new(error.message)
        reerror.set_backtrace(error.backtrace)
        raise reerror
      rescue Excon::Errors::Error => error
        reerror = Heroku::API::Errors::Error.new(error.message)
        reerror.set_backtrace(error.backtrace)
        raise reerror
      end

      if response.body && !response.body.empty?
        response.body = Zlib::GzipReader.new(StringIO.new(response.body)).read
        begin
          response.body = Heroku::API::OkJson.decode(response.body)
        rescue
          # leave non-JSON body as is
        end
      end

      # reset (non-persistent) connection
      @connection.reset

      response
    end

    private

    def app_params(params)
      app_params = {}
      params.each do |key, value|
        app_params["app[#{key}]"] = value
      end
      app_params
    end

    def addon_params(params)
      {:config => params}
    end
  end
end
