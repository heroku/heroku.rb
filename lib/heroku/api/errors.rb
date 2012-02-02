module Heroku
  class API
    module Errors
      class Error < StandardError; end

      class NotFound < Error; end
    end
  end
end
