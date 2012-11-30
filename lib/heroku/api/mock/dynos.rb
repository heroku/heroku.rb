module Heroku
  class API
    module Mock

    # stub GET /apps/:app/dynos
    Excon.stub(:expects => 200, :method => :get, :path => %r{^/apps/([^/]+)/dynos}) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]
      with_mock_app(mock_data, app) do |app_data|
        {
          :body   => Heroku::API::OkJson.encode(get_mock_dynos(mock_data, app)),
          :status => 200
        }
      end
    end

    # stub POST /apps/:app/dynos
    Excon.stub(:expects => 200, :method => :post, :path => %r{^/apps/([^/]+)/dynos}) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]
      with_mock_app(mock_data, app) do |app_data|
        attached = request_params[:query].has_key?('attach')
        command  = request_params[:query].has_key?('command') && request_params[:query]['command']
        rendezvous_url = if attached
          "s1.runtime.heroku.com:5000/#{SecureRandom.hex(32)}"
        end
        max_run_id = mock_data[:ps][app].map { |process| process['name'].split('run.').last.to_i}.max
        data = {
          'action'          => 'complete',
          'app'             => { 'id' => app_data['id'] },
          'attached'        => attached,
          'command'         => command,
          'elapsed'         => 0,
          'name'            => "run.#{max_run_id + 1}",
          'rendezvous_url'  => rendezvous_url,
          'slug'            => 'NONE',
          'state'           => 'created',
          'transitioned_at' => timestamp,
          'type'            => { 'name' => 'run' },
          'upid'            => rand(99999999).to_s
        }
        mock_data[:ps][app] << data
        {
          :body   => Heroku::API::OkJson.encode(data),
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

    # stub POST /apps/:app/ps/stop
    Excon.stub(:expects => 200, :method => :post, :path => %r{^/apps/([^/]+)/ps/stop}) do |params|
      request_params, mock_data = parse_stub_params(params)
      app, _ = request_params[:captures][:path]
      with_mock_app(mock_data, app) do |app_data|
        ps = request_params[:query].has_key?('ps') && request_params[:query]['ps']
        type  = request_params[:query].has_key?('type') && request_params[:query]['type']
        if !ps && !type
          {
            :body   => Heroku::API::OkJson.encode({'error' => 'Missing process argument'}),
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
            :body   => Heroku::API::OkJson.encode({'name' => app, 'dynos' => dynos}),
            :status => 200
          }
        else
          {
            :body   => Heroku::API::OkJson.encode({'error' => "For Cedar apps, use `heroku scale web=#{dynos}`"}),
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
            :body   => Heroku::API::OkJson.encode({'name' => app, 'workers' => workers}),
            :status => 200
          }
        else
          {
            :body   => Heroku::API::OkJson.encode({'error' => "For Cedar apps, use `heroku scale worker=#{workers}`"}),
            :status => 422
          }
        end
      end
    end

    end
  end
end
