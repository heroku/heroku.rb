require 'excon'

module Heroku
  class Connection < Excon::Connection
    VERSION = "0.0.1"
  end
end
