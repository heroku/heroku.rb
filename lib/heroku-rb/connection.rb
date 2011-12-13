module Heroku
  class Connection < Excon::Connection

    def initialize(options={})
      api_key = options.delete(:heroku_api_key) || ENV['HEROKU_API_KEY']
      user_pass = ":#{api_key}"
      options[:headers] ||= {}
      options[:headers]['Accept'] ||= 'application/json'
      options[:headers]['Authorization'] ||= "Basic #{Base64.encode64(user_pass).gsub("\n", '')}"
      options[:host] ||= 'api.heroku.com'
      options[:scheme] ||= 'https'
      super("#{options[:scheme]}://#{options[:host]}", options)
    end

    def apps
      get(:path => 'apps').body
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
