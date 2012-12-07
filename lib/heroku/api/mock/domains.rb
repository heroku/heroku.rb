module Heroku
  class API
    module Mock

      # stub DELETE /apps/:app/domains
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/apps/([^/]+)/domains$} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do |app_data|
          deleted_domain = mock_data[:domains][app].detect do |domain|
            domain['domain'] == request_params[:query]['domain']
          end
          if deleted_domain
            mock_data[:domains][app].delete(deleted_domain)
            {
              :body   => deleted_domain,
              :status => 200
            }
          else
            {
              :body   => 'Domain not found.',
              :status => 404
            }
          end
        end
      end

      # stub GET /apps/:app/domains
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/domains$} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do |app_data|
          {
            :body   => MultiJson.encode(mock_data[:domains][app]),
            :status => 200
          }
        end
      end

      # stub POST /apps/:app/domains
      Excon.stub(:expects => 201, :method => :post, :path => %r{^/apps/([^/]+)/domains$} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        domain = request_params[:query]['domain']
        with_mock_app(mock_data, app) do |app_data|
          unless get_mock_app_domain(mock_data, app, domain)
            base = domain.split('.')[-2..-1].join('.')
            mock_data[:domains][app] << {
              'app'         => { 'id' => app_data['id'] },
              'base'        => base,
              'domain'      => domain,
              'id'          => base,
            }
          end
          {
            :body   => MultiJson.encode(mock_data[:domains][app].last),
            :status => 201
          }
        end
      end

    end
  end
end
