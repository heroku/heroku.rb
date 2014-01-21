module Heroku
  class API
    module Mock

    # stub GET /apps/:app/ps
    Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/ps}) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]
      with_mock_app(mock_data, app) do |app_data|
        {
          :body   => MultiJson.dump(get_mock_processes(mock_data, app)),
          :status => 200
        }
      end
    end

    # stub POST /apps/:app/ps
    Excon.stub(:expects => 200, :method => :post, :path => %r{^/apps/([^/]+)/ps\/?$}) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]
      with_mock_app(mock_data, app) do |app_data|
        unless attached = request_params[:query].has_key?('attach') && request_params[:query]['attach'].to_s == 'true'
          type = 'Ps'
        end
        command = request_params[:query].has_key?('command') && request_params[:query]['command']
        size    = request_params[:query]['size']
        rendezvous_url = if attached
          "s1.runtime.heroku.com:5000/#{SecureRandom.hex(32)}"
        end
        max_run_id = mock_data[:ps][app].map { |process| process['process'].split('run.').last.to_i}.max
        data = {
          'action'          => 'complete',
          'attached'        => attached,
          'command'         => command,
          'elapsed'         => 0,
          'pretty_state'    => 'completed for 0s',
          'process'         => "run.#{max_run_id + 1}",
          'rendezvous_url'  => rendezvous_url,
          'size'            => size,
          'slug'            => 'NONE',
          'state'           => 'created',
          'transitioned_at' => timestamp,
          'type'            => type,
          'upid'            => rand(99999999).to_s
        }
        mock_data[:ps][app] << data
        {
          :body   => MultiJson.dump(data),
          :status => 200,
        }
      end
    end

    # stub POST /apps/:app/ps/restart
    Excon.stub(:expects => 200, :method => :post, :path => %r{^/apps/([^/]+)/ps/restart}) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]
      with_mock_app(mock_data, app) do |app_data|
        ps = request_params[:query].has_key?('ps') && request_params[:query]['ps']
        type  = request_params[:query].has_key?('type') && request_params[:query]['type']
        if !ps && !type
          mock_data[:ps][app].select {|process| process['state'] != 'complete'}.each do |process|
            process['transitioned_at'] = timestamp
          end
        elsif ps
          mock_data[:ps][app].select {|process| process['process'] == 'ps' && process['state'] != 'complete'}.each do |process|
            process['transitioned_at'] = timestamp
          end
        elsif type
          mock_data[:ps][app].select {|process| process['process'] =~ %r{^#{type}\.\d+} && process['state'] != 'complete'}.each do |process|
            process['transitioned_at'] = timestamp
          end
        end
        {
          :body   => 'ok',
          :status => 200
        }
      end
    end

    # stub POST /apps/:app/ps/scale
    Excon.stub(:expects => 200, :method => :post, :path => %r{^/apps/([^/]+)/ps/scale}) do |params|
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
              :body   => MultiJson.dump('error' => "No such type as #{type}") ,
              :status => 422
            }
          end
        else
          {
            :body   => MultiJson.dump('error' => "That feature is not available on this app's stack"),
            :status => 422
          }
        end
      end
    end

    # stub POST /apps/:app/ps/stop
    Excon.stub(:expects => 200, :method => :post, :path => %r{^/apps/([^/]+)/ps/stop}) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]
      with_mock_app(mock_data, app) do |app_data|
        ps = request_params[:query].has_key?('ps') && request_params[:query]['ps']
        type  = request_params[:query].has_key?('type') && request_params[:query]['type']
        if !ps && !type
          {
            :body   => MultiJson.dump({'error' => 'Missing process argument'}),
            :status => 422
          }
        else
          {
            :body   => 'ok',
            :status => 200
          }
        end
      end
    end

    # stub PUT /apps/:app/dynos
    Excon.stub(:expects => 200, :method => :put, :path => %r{^/apps/([^/]+)/dynos}) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]
      with_mock_app(mock_data, app) do |app_data|
        dynos = request_params[:query].has_key?('dynos') && request_params[:query]['dynos'].to_i
        unless app_data['stack'] == 'cedar'
          app_data['dynos'] = dynos
          {
            :body   => MultiJson.dump({'name' => app, 'dynos' => dynos}),
            :status => 200
          }
        else
          {
            :body   => MultiJson.dump({'error' => "For Cedar apps, use `heroku scale web=#{dynos}`"}),
            :status => 422
          }
        end
      end
    end

    # stub PUT /apps/:app/workers
    Excon.stub(:expects => 200, :method => :put, :path => %r{^/apps/([^/]+)/workers}) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]
      with_mock_app(mock_data, app) do |app_data|
        workers = request_params[:query].has_key?('workers') && request_params[:query]['workers'].to_i
        unless app_data['stack'] == 'cedar'
          app_data['workers'] = workers
          {
            :body   => MultiJson.dump({'name' => app, 'workers' => workers}),
            :status => 200
          }
        else
          {
            :body   => MultiJson.dump({'error' => "For Cedar apps, use `heroku scale worker=#{workers}`"}),
            :status => 422
          }
        end
      end
    end

    # stub PUT /apps/:app/formation
    Excon.stub(:expects => 200, :method => :put, :path => %r{^/apps/([^/]+)/formation}) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]
      with_mock_app(mock_data, app) do
        new_resize_vars = request_params[:body]
        process = mock_data[:ps][app].first["process"].split('.')[0]
        size = new_resize_vars[process]["size"][/[(\d+)P]/]
        mock_data[:ps][app].first.merge!({'size' => size})
        {
          :body   => MultiJson.dump(get_mock_processes(mock_data, app)),
          :status => 200
        }
      end
    end

    # stub GET /apps/:app/dyno-types
    Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/dyno-types}) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]
      with_mock_app(mock_data, app) do |app_data|
        {
          :body   => MultiJson.dump([{"command"=>"bundle exec rails console", "name"=>"console", "quantity"=>0}]),
          :status => 200
        }
      end
    end



    end
  end
end
