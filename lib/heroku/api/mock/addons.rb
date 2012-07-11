module Heroku
  class API
    module Mock

      # stub DELETE /apps/:app/addons/:addon
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/apps/([^/]+)/addons/([^/]+)$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, addon, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          addon_names = mock_data[:addons][app].map {|data| data['name']}
          if addon_data = get_mock_addon(mock_data, addon)
            # addon exists
            if app_addon_data = get_mock_app_addon(mock_data, app, addon)
              # addon is currently installed
              remove_mock_app_addon(mock_data, app, addon)
              {
                :body   => Heroku::API::OkJson.encode({
                  "message" => nil,
                  "price"   => get_mock_addon_price(mock_data, addon),
                  "status"  => 'Uninstalled'
                }),
                :status => 200
              }
            else
              # addon is not currently installed
              {
                :body   => Heroku::API::OkJson.encode({'error' => "The add-on #{addon} is not installed for this app. Did you mean:\n\t#{addon_names.join("\n\t")}"}),
                :status => 422
              }
            end
          else
            # addon does not exist
            {
              :body   => Heroku::API::OkJson.encode({'error' => "Could not find add-on #{addon}. Did you mean:\n\t#{addon_names.join("\n\t")}"}),
              :status => 422
            }
          end
        end
      end

      # stub GET /addons
      Excon.stub(:expects => 200, :method => :get, :path => "/addons") do |params|
        request_params, mock_data = parse_stub_params(params)
        {
          :body   => File.read("#{File.dirname(__FILE__)}/cache/get_addons.json"),
          :status => 200
        }
      end

      # stub GET /apps/:app/addons
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/addons$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          {
            :body   => Heroku::API::OkJson.encode(mock_data[:addons][app].map {|addon| addon['configured'] = true; addon}),
            :status => 200
          }
        end
      end

      # stub POST /apps/:app/addons
      Excon.stub(:expects => 200, :method => :post, :path => %r{^/apps/([^/]+)/addons/([^/]+)$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, addon, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          if addon_data = get_mock_addon(mock_data, addon)
            # addon exists
            unless app_addon_type_data = mock_data[:addons][app].detect {|data| data['name'] =~ %r{^#{addon.split(':').first}}}
              # addon of same type does not exist
              unless app_addon_data = get_mock_app_addon(mock_data, app, addon)
                # addon is not currently installed
                add_mock_app_addon(mock_data, app, addon)
                {
                  :body   => Heroku::API::OkJson.encode({
                    "message" => nil,
                    "price"   => get_mock_addon_price(mock_data, addon),
                    "status"  => 'Installed'
                  }),
                  :status => 200
                }
              else
                # addon is currently installed
                {
                  :body   => Heroku::API::OkJson.encode({'error' => "Add-on already installed."}),
                  :status => 422
                }
              end
            else
              # addon of same type exists
              {
                :body   => Heroku::API::OkJson.encode({'error' => "#{app_addon_type_data['name']} add-on already added.\nTo upgrade, use addons:upgrade instead.\n"}),
                :status => 422
              }
            end
          else
            # addon does not exist
            {
              :body   => Heroku::API::OkJson.encode({'error' => "Add-on not found."}),
              :status => 404
            }
          end
        end
      end

      # stub PUT /apps/:app/addons
      Excon.stub(:expects => 200, :method => :put, :path => %r{^/apps/([^/]+)/addons/([^/]+)$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, addon, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          if addon_data = get_mock_addon(mock_data, addon)
            # addon exists
            if mock_data[:addons][app].detect {|data| data['name'] =~ %r{^#{addon.split(':').first}}}
              # addon of same type exists
              unless app_addon_data = get_mock_app_addon(mock_data, app, addon)
                # addon is not currently installed
                mock_data[:addons][app].delete(app_addon_data)
                add_mock_app_addon(mock_data, app, addon)
                {
                  :body   => Heroku::API::OkJson.encode({
                    "message" => 'Plan upgraded',
                    "price"   => get_mock_addon_price(mock_data, addon),
                    "status"  => 'Updated'
                  }),
                  :status => 200
                }
              else
                # addon is currently installed
                {
                  :body   => Heroku::API::OkJson.encode({'error' => "Add-on already installed."}),
                  :status => 422
                }
              end
            else
              # addon of same type not installed
              {
                :body   => Heroku::API::OkJson.encode({'error' => "Can't upgrade, no #{addon.split(':').join(' ')} add-on has been added.\nTo add, use addons:add instead.\n"}),
                :status => 422
              }
            end
          else
            # addon does not exist
            {
              :body   => Heroku::API::OkJson.encode({'error' => "Add-on not found."}),
              :status => 404
            }
          end
        end
      end

    end
  end
end
