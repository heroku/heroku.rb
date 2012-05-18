module Heroku
  class API
    module Mock

      # stub GET /apps/:app/releases
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/releases$} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do |app_data|
          {
            :body   => Heroku::API::OkJson.encode(mock_data[:releases][app]),
            :status => 200
          }
        end
      end

      # stub GET /apps/:app/releases/:release
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/releases/([^/]+)$} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, release_name, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do |app_data|
          releases = mock_data[:releases][app]
          if release_data = (release_name == 'current' && releases.last) || releases.detect {|release| release['name'] == release_name}
            {
              :body   => Heroku::API::OkJson.encode(release_data),
              :status => 200
            }
          else
            {
              :body   => 'Record not found.',
              :status => 404
            }
          end
        end
      end

      # stub POST /apps/:app/releases/:release
      Excon.stub(:expects => 200, :method => :post, :path => %r{^/apps/([^/]+)/releases} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        release_name = request_params[:query]['rollback']
        with_mock_app(mock_data, app) do |app_data|
          releases = mock_data[:releases][app]
          if release_data = releases.detect {|release| release['name'] == release_name}
            if release_data['addons'] == mock_data[:releases][app].last['addons']
              version = mock_data[:releases][app].map {|release| release['name'][1..-1].to_i}.max || 0
              env = if get_mock_app(mock_data, app)['stack'] == 'cedar'
                {
                  'BUNDLE_WITHOUT'      => 'development:test',
                  'DATABASE_URL'        => 'postgres://username:password@ec2-123-123-123-123.compute-1.amazonaws.com/username',
                  'LANG'                => 'en_US.UTF-8',
                  'RACK_ENV'            => 'production',
                  'SHARED_DATABASE_URL' => 'postgres://username:password@ec2-123-123-123-123.compute-1.amazonaws.com/username'
                }
              else
                {}
              end
              mock_data[:releases][app] << {
                'addons'      => mock_data[:addons][app].map {|addon| addon['name']},
                'commit'      => nil,
                'created_at'  => timestamp,
                'descr'       => "Rollback to #{release_name}",
                'env'         => env,
                'name'        => "v#{version + 1}",
                'pstable'     => { 'web' => '' },
                'user'        => 'email@example.com'
              }

              {
                :body   => release_data['name'],
                :status => 200
              }
            else
              {
                :body   => Heroku::API::OkJson.encode({'error' => 'Cannot rollback to a release that had a different set of addons installed'}),
                :status => 422
              }
            end
          else
            {
              :body   => 'Record not found.',
              :status => 404
            }
          end
        end
      end

    end
  end
end
