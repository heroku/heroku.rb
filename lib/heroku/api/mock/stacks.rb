module Heroku
  class API
    module Mock

      STACKS = [
        {
          "beta"      => false,
          "requested" => false,
          "current"   => false,
          "name"      => "aspen-mri-1.8.6"
        },
        {
          "beta"      => false,
          "requested" => false,
          "current"   => false,
          "name"      => "bamboo-mri-1.9.2"
        },
        {
          "beta"      => false,
          "requested" => false,
          "current"   => false,
          "name"      => "bamboo-ree-1.8.7"
        },
        {
          "beta"      => true,
          "requested" => false,
          "current"   => false,
          "name"      => "cedar"
        }
      ]

      # stub GET /apps/:app/stack
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/stack}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do |app_data|
          stack_data = Marshal::load(Marshal.dump(STACKS))
          stack_data.detect {|stack| stack['name'] == app_data['stack']}['current'] = true
          {
            :body   => Heroku::API::OkJson.encode(stack_data),
            :status => 200
          }
        end
      end

      # stub PUT /apps/:app/stack
      Excon.stub(:expects => 200, :method => :put, :path => %r{^/apps/([^/]+)/stack}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        stack = request_params[:body]
        with_mock_app(mock_data, app) do |app_data|
          if app_data['stack'] != 'cedar' && stack != 'cedar'
            if STACKS.map {|stack_data| stack_data['name']}.include?(stack)
              {
                :body   => <<-BODY,
HTTP/1.1 200 OK
-----> Preparing to migrate #{app}
       #{app_data['stack']} -> #{stack}

       NOTE: Additional details here

       -----> Migration prepared.
       Run 'git push heroku master' to execute migration.
BODY
                :status => 200
              }
            else
              {
                :body   => Heroku::API::OkJson.encode('error' => 'Stack not found'),
                :status => 404
              }
            end
          else
            {
              :body   => Heroku::API::OkJson.encode('error' => 'Stack migration to/from Cedar is not available. Create a new app with --stack cedar instead.'),
              :status => 422
            }
          end
        end
      end

    end
  end
end
