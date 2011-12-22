module Heroku
  class API < Excon::Connection
    module Mock

      APP_NOT_FOUND = { :body => 'App not found.', :status => 404 }

      @mock_data = Hash.new do |hash, key|
        hash[key] = {
          :apps             => [],
          :collaborators    => {},
          :maintenance_mode => [],
          :config_vars      => {}
        }
      end

      def self.get_mock_app(mock_data, app)
        mock_data[:apps].detect {|app_data| app_data['name'] == app}
      end

      def self.parse_stub_params(params)
        api_key = Base64.decode64(params[:headers]['Authorization']).split(':').last

        parsed = params.dup
        if parsed[:body]
          begin # try to JSON decode
            parsed[:body] = Heroku::OkJson.decode(parsed[:body])
          rescue # else CGI parse
            parsed[:body] = CGI.parse(parsed[:body])
            # returns key => ['value'], so we now remove from arrays
            parsed[:body].each do |key, value|
              parsed[:body][key] = value.first
            end
          end
        else
          parsed[:body] = {}
        end

        [parsed, @mock_data[api_key]]
      end

      def self.with_mock_app(mock_data, app, &block)
        if app_data = get_mock_app(mock_data, app)
          yield(app_data)
        else
          APP_NOT_FOUND
        end
      end

    end
  end
end
