module Heroku
  class API
    module Mock

      # stub DELETE /features/:feature
      Excon.stub(:expects => 200, :method => :delete, :path => %r{^/features/([^/]+)$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app = request_params[:query].has_key?('app') && request_params[:query]['app']
        feature, _ = request_params[:captures][:path]
        if !app || get_mock_app(mock_data, app)
          # app found
          if feature_data = get_mock_feature(mock_data, feature)
            feature_data = feature_data.merge('enabled' => true)
            # feature exists
            case feature_data['kind']
            when 'app'
              mock_data[:features][:app][app].delete(feature_data)
              {
                :body   => Heroku::API::OkJson.encode(feature_data.merge('enabled' => false)),
                :status => 200
              }
            when 'user'
              mock_data[:features][:user].delete(feature_data.merge('enabled' => false))
              {
                :body   => Heroku::API::OkJson.encode(feature_data),
                :status => 200
              }
            end
          else
            # feature does not exist
            {
              :body   => Heroku::API::OkJson.encode({'error' => "Feature not found."}),
              :status => 404
            }
          end
        else
          {
            :body   => 'Feature not enabled.',
            :status => 422
          }
        end
      end

      # stub GET /features
      Excon.stub(:expects => 200, :method => :get, :path => %r|^/features$|) do |params|
        request_params, mock_data = parse_stub_params(params)
        {
          :body   => File.read("#{File.dirname(__FILE__)}/cache/get_features.json"),
          :status => 200
        }
      end

      # stub GET /features/:feature
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/features/([^/]+)}) do |params|
        request_params, mock_data = parse_stub_params(params)
        feature, _ = request_params[:captures][:path]
        if feature_data = get_mock_feature(mock_data, feature)
          {
            :body   => Heroku::API::OkJson.encode(feature_data),
            :status => 200
          }
        else
          # feature does not exist
          {
            :body   => Heroku::API::OkJson.encode({'error' => "Feature not found."}),
            :status => 404
          }
        end
      end

      # stub POST /features/:feature
      Excon.stub(:expects => [200, 201], :method => :post, :path => %r{^/features/([^/]+)$}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app = request_params[:query].has_key?('app') && request_params[:query]['app']
        feature, _ = request_params[:captures][:path]
        if !app || get_mock_app(mock_data, app)
          # app found
          if feature_data = get_mock_feature(mock_data, feature)
            feature_data = feature_data.merge('enabled' => true)
            # feature exists
            case feature_data['kind']
            when 'app'
              status = if mock_data[:features][:app][app].include?(feature_data)
                200
              else
                mock_data[:features][:app][app] << feature_data
                201
              end
              {
                :body   => Heroku::API::OkJson.encode(feature_data),
                :status => status
              }
            when 'user'
              status = if mock_data[:features][:user].include(feature_data)
                200
              else
                mock_data[:features][:user] << feature_data
                201
              end
              {
                :body   => '',
                :status => status
              }
            end
          else
            # feature does not exist
            {
              :body   => Heroku::API::OkJson.encode({'error' => "Feature not found."}),
              :status => 404
            }
          end
        else
          # app not found
          Heroku::API::Mock::APP_NOT_FOUND
        end
      end

    end
  end
end
