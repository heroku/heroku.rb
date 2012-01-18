module Heroku
  class API < Excon::Connection
    module Mock

      # stub DELETE /apps/:app/domains/:domain
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/apps/([^/]+)/domains/([^/]+)$} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, domain, _ = request_params[:captures][:path]
        domain = CGI.unescape(domain)
        with_mock_app(mock_data, app) do |app_data|
          if domain = get_mock_app_domain(mock_data, app, domain)
            mock_data[:domains][app].delete(domain)
            {
              :body   => {},
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
            :body   => Heroku::OkJson.encode(mock_data[:domains][app]),
            :status => 200
          }
        end
      end

      # stub POST /apps/:app/domains
      Excon.stub(:expects => 200, :method => :post, :path => %r{^/apps/([^/]+)/domains$} ) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        domain = request_params[:query]['domain_name[domain]']
        with_mock_app(mock_data, app) do |app_data|
          if ['custom_domains:basic', 'custom_domains:wildcard'].any? {|addon| get_mock_app_addon(mock_data, app, addon)}
            unless get_mock_app_domain(mock_data, app, domain)
              mock_data[:domains][app] << {
                'app_id'      => app_data['id'],
                'base_domain' => domain.split('.')[-2..-1].join('.'),
                'created_at'  => timestamp,
                'domain'      => domain,
                'default'     => nil,
                'id'          => rand(999999),
                'updated_at'  => timestamp
              }
            end
            {
              :body   => Heroku::OkJson.encode('domain' => domain),
              :status => 200
            }
          else
            {
              :body   => Heroku::OkJson.encode([["base","Please install the Custom Domains addon before adding domains to your app"]]),
              :status => 422
            }
          end
        end
      end

    end
  end
end
