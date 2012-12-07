module Heroku
  class API
    module Mock

      # stub PUT /apps/:app/dyno-types
      Excon.stub(:expects => 200, :method => :post, :path => %r{^/apps/([^/]+)/dyno-types}) do |params|
        request_params, mock_data = parse_stub_params(params)
        app, _ = request_params[:captures][:path]
        with_mock_app(mock_data, app) do |app_data|
          type = request_params[:query].has_key?('type') && request_params[:query]['type']
          qty = request_params[:query].has_key?('qty') && request_params[:query]['qty']
          if app_data['stack'] == 'cedar'
            if type == 'web'
              current_qty = mock_data[:ps][app].count {|process| process['process'] =~ %r{^web\.\d+}}

              new_qty = case qty
              when /[+-]\d+/
                current_qty + qty.to_i
              else
                qty.to_i
              end

              if new_qty >= current_qty
                (new_qty - current_qty).times do
                  max_web_id = mock_data[:ps][app].map {|process| process['process'].split('web.').last.to_i}.max
                  data = mock_data[:ps][app].first.merge({
                    'process'         => "web.#{max_web_id + 1}",
                    'transitioned_at' => timestamp,
                    'upid'            => rand(99999999).to_s
                  })
                  mock_data[:ps][app] << data
                end
              elsif new_qty < current_qty
                (current_qty - new_qty).times do
                  max_web_id = mock_data[:ps][app].map {|process| process['process'].split('web.').last.to_i}.max
                  process = mock_data[:ps][app].detect {|process| process['process'] == "web.#{max_web_id}"}
                  mock_data[:ps][app].delete(process)
                end
              end
              {
                :body   => new_qty.to_s,
                :status => 200
              }
            else
              {
                :body   => MultiJson.encode('error' => "No such type as #{type}") ,
                :status => 422
              }
            end
          else
            {
              :body   => MultiJson.encode('error' => "That feature is not available on this app's stack"),
              :status => 422
            }
          end
        end
      end

    end
  end
end
