module Heroku
  class Connection < Excon::Connection

    # DELETE /apps/:name
    def delete_app(name)
      request(:expects => 200, :method => :delete, :path => "/apps/#{name}").body
    end

    # stub DELETE /apps/:name
    Excon.stub(:expects => 200, :method => :delete, :path => %r{/apps/\S+}) do |params|
      name = %r{/apps/(\S+)}.match(params[:path]).captures.first
      if app = mock_data[:apps].detect {|app| app['name'] == name}
        mock_data[:apps].delete(app)
        {
          :body   => Heroku::OkJson.encode({}),
          :status => 200
        }
      else
        {
          :body   => 'App not found.',
          :status => 404
        }
      end
    end

    # GET /apps
    def get_apps
      request(:expects => 200, :method => :get, :path => "/apps").body
    end

    # stub GET /apps/
    Excon.stub(:expects => 200, :method => :get, :path => '/apps') do |params|
      {
        :body   => Heroku::OkJson.encode(Heroku::Connection.mock_data[:apps]),
        :status => 200
      }
    end

    # GET /apps/:name
    def get_app(name)
      request(:expects => 200, :method => :get, :path => "/apps/#{name}").body
    end

    # stub GET /apps/:name
    Excon.stub(:expects => 200, :method => :get, :path => %r{/apps/\S+}) do |params|
      name = %r{/apps/(\S+)}.match(params[:path]).captures.first
      if app = mock_data[:apps].detect {|app| app['name'] == name}
        {
          :body   => Heroku::OkJson.encode(app),
          :status => 200
        }
      else
        {
          :body   => 'App not found.',
          :status => 404
        }
      end
    end

    # POST /apps
    def post_app(params={})
      request(:body => {'app' => params}, :expects => 202, :method => :post, :path => '/apps').body
    end

    # stub POST /apps
    Excon.stub(:expects => 202, :method => :post, :path => '/apps') do |params|
      if params[:body]
        data = CGI.parse(params[:body])
      else
        data = {}
      end

      name = data['app[name]'].first || "generated-name-#{rand(999)}"

      if mock_data[:apps].detect {|app| app['name'] == name}
        {
          :body => Heroku::OkJson.encode('error' => 'Name is already taken'),
          :status => 422
        }
      else
        app = {
          'created_at'          => Time.now.strftime("%G/%d/%m %H:%M:%S %z"),
          'create_status'       => 'complete',
          'id'                  => rand(99999),
          'name'                => name,
          'owner_email'         => 'email@example.com',
          'stack'               => data['app[stack]'].first || 'bamboo-mri-1.9.2',
          'slug_size'           => nil,
          'requested_stack'     => nil,
          'git_url'             => "git@heroku.com:#{name}.git",
          'repo_migrate_status' => 'complete',
          'repo_size'           => nil,
          'dynos'               => 0,
          'web_url'             => "http://#{name}.herokuapp.com/",
          'workers'             => 0

        }

        mock_data[:apps] << app
        {
          :body   => Heroku::OkJson.encode(app),
          :status => 202
        }
      end
    end

  end
end
