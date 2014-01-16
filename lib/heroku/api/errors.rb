module Heroku
  class API
    module Errors
      class Error < StandardError; end

      class ErrorWithResponse < Error
        attr_reader :response

        def initialize(message, response)
          message = message << "\nbody: #{response.body.inspect}"
          super message
          @response = response
        end
      end

      class Unauthorized < ErrorWithResponse; end
      class VerificationRequired < ErrorWithResponse; end
      class Forbidden < ErrorWithResponse; end
      class NotFound < ErrorWithResponse; end
      class Timeout < ErrorWithResponse; end
      class Locked < ErrorWithResponse; end
      class RateLimitExceeded < ErrorWithResponse; end
      class RequestFailed < ErrorWithResponse; end
      class NilApp < ErrorWithResponse; end

    end
  end
end
