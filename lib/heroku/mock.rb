module Heroku
  class Connection < Excon::Connection

    @mock_data = Hash.new do |hash, key|
      hash[key] = {
        :apps             => [],
        :maintenance_mode => [],
        :config_vars      => {}
      }
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

  end
end
