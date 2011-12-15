module Heroku
  class Apps

    def initialize(connection)
      @connection = connection
    end

    def all
      @connection.get(:expects => 200, :path => '/apps').body
    end

    Excon.stub({:method => :get, :path => '/apps'}) do |params|
      {
        :body   => Heroku::OkJson.encode(Heroku::Connection.mock_data[:apps]),
        :status => 200
      }
    end

    def get(name)
      @connection.get(:expects => 200, :path => "/apps/#{name}").body
    end

    Excon.stub({:method => :get, :path => %r{/apps/(\S+)}}) do |params|
      name = %r{/apps/(\S+)}.match(params[:path]).captures.first
      if app = Heroku::Connection.mock_data[:apps].detect {|app| app['name'] == name}
        {
          :body   => Heroku::OkJson.encode(app),
          :status => 200
        }
      else
        {
          :status => 404
        }
      end
    end

  end

  class Connection < Excon::Connection

    def apps
      Heroku::Apps.new(self)
    end

  end
end
