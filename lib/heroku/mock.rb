module Heroku
  class Connection < Excon::Connection

    @mock_data = Hash.new do |hash, key|
      hash[key] = {
        :apps             => [],
        :maintenance_mode => []
      }
    end

    # store of info to use for mocks
    def self.mock_data
      @mock_data
    end

  end
end
