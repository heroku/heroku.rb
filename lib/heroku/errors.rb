module Heroku
  module Errors
    class Error < StandardError; end

    class NotFound < Error; end
  end
end
