require "base64"
require "excon"
require "securerandom"
require "uri"
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
require "heroku/api/attachments"
require "heroku/api/collaborators"
require "heroku/api/config_vars"
require "heroku/api/domains"
require "heroku/api/features"
require "heroku/api/keys"
require "heroku/api/login"
require "heroku/api/logs"
require "heroku/api/processes"
require "heroku/api/releases"
require "heroku/api/ssl_endpoints"
require "heroku/api/stacks"
require "heroku/api/user"

srand

module Heroku
  class API

    HEADERS = {
      'Accept'                => 'application/json',
      'Accept-Encoding'       => 'gzip',
      #'Accept-Language'       => 'en-US, en;q=0.8',
      'User-Agent'            => "heroku-rb/#{Heroku::API::VERSION}",
      'X-Ruby-Version'        => RUBY_VERSION,
      'X-Ruby-Platform'       => RUBY_PLATFORM
    }

    OPTIONS = {
      :headers  => {},
      :host     => 'api.heroku.com',
      :nonblock => false,
      :scheme   => 'https'
    }

    def initialize(options={})
      options = OPTIONS.merge(options)

      @api_key = options.delete(:api_key) || ENV['HEROKU_API_KEY']
      if !@api_key && options.has_key?(:username) && options.has_key?(:password)
        @connection = Excon.new("#{options[:scheme]}://#{options[:host]}", options.merge(:headers => HEADERS))
        @api_key = self.post_login(options[:username], options[:password]).body["api_key"]
      end

      user_pass = ":#{@api_key}"
      options[:headers] = HEADERS.merge({
        'Authorization' => "Basic #{Base64.encode64(user_pass).gsub("\n", '')}",
      }).merge(options[:headers])

      @connection = Excon.new("#{options[:scheme]}://#{options[:host]}", options)
    end

    def request(params, &block)
      begin
        response = @connection.request(params, &block)
      rescue Excon::Errors::HTTPStatusError => error
        klass = case error.response.status
          when 401 then Heroku::API::Errors::Unauthorized
          when 402 then Heroku::API::Errors::VerificationRequired
          when 403 then Heroku::API::Errors::Forbidden
          when 404 then Heroku::API::Errors::NotFound
          when 408 then Heroku::API::Errors::Timeout
          when 422 then Heroku::API::Errors::RequestFailed
          when 423 then Heroku::API::Errors::Locked
          when /50./ then Heroku::API::Errors::RequestFailed
          else Heroku::API::Errors::ErrorWithResponse
        end

        reerror = klass.new(error.message, error.response)
        reerror.set_backtrace(error.backtrace)
        raise(reerror)
      end

      if response.body && !response.body.empty?
        if response.headers['Content-Encoding'] == 'gzip'
          response.body = Zlib::GzipReader.new(StringIO.new(response.body)).read
        end
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
      params.inject({}) do |accum, (key, value)|
        accum["config[#{key}]"] = value
        accum
      end
    end

    def escape(string)
      CGI.escape(string).gsub('.', '%2E')
    end

    def ps_options(params)
      if ps_env = params.delete(:ps_env) || params.delete('ps_env')
        ps_env.each do |key, value|
          params["ps_env[#{key}]"] = value
        end
      end
      params
    end

  end
end
