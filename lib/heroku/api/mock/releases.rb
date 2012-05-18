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
        release_name = request_params[:query]['rollback'] || mock_data[:releases][app][-2] && mock_data[:releases][app][-2]['name']
        with_mock_app(mock_data, app) do |app_data|
          releases = mock_data[:releases][app]
          if release_data = releases.detect {|release| release['name'] == release_name}
            if release_data['addons'] == mock_data[:releases][app].last['addons']
              add_mock_release(mock_data, app, {'descr' => "Rollback to #{release_name}"})

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
