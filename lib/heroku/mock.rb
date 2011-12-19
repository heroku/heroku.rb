module Heroku
  class Connection < Excon::Connection

    @mock_data = Hash.new do |hash, key|
      hash[key] = {
        :apps             => [],
        :maintenance_mode => []
      }
    end

    def self.parse_stub_params(params)
      api_key = Base64.decode64(params[:headers]['Authorization']).split(':').last

      parsed = params.dup
      parsed[:body] = parsed[:body] && CGI.parse(parsed[:body]) || {}

      [parsed, @mock_data[api_key]]
    end

  end
end
