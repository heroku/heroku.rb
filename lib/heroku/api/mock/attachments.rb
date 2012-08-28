module Heroku
  class API
    module Mock

      # stub GET /apps/:app/attachments
      Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/attachments}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do
          {
            :body   => Heroku::API::OkJson.encode(mock_data[:attachments][app]),
            :status => 200
          }
        end
      end

    end
  end
end
