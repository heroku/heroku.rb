module Heroku
  class Connection < Excon::Connection

    # store of info to use for mocks
    @mock_data = {
      :apps => []
    }
    def self.mock_data
      @mock_data
    end

  end
end
