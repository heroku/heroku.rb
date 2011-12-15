require 'heroku-rb/apps'

module Heroku
  class Connection < Excon::Connection

    def initialize(options={})
      api_key = options.delete(:heroku_api_key) || ENV['HEROKU_API_KEY']
      user_pass = ":#{api_key}"
      options = {
        :headers  => {},
        :host     => 'api.heroku.com',
        :scheme   => 'https'
      }.merge(options)
      options[:headers] = {
        'Accept'                => 'application/json',
        'Authorization'         => "Basic #{Base64.encode64(user_pass).gsub("\n", '')}",
        'User-Agent'            => "heroku-rb/#{VERSION}",
        'X-Heroku-API-Version'  => '3',
        'X-Ruby-Version'        => RUBY_VERSION,
        'X-Ruby-Platform'       => RUBY_PLATFORM
      }.merge(options[:headers])
      super("#{options[:scheme]}://#{options[:host]}", options)
    end

    def apps
      Heroku::Apps.new(self)
    end

    def request(params, &block)
      if params[:body]
        params[:body] = Heroku::OkJson.encode(params[:body])
      end
      response = super
      if response.body && !response.body.empty?
        response.body = Heroku::OkJson.decode(response.body)
      end
      response
    end

  end
end
