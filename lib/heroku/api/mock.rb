require 'heroku/api/mock/addons'
require 'heroku/api/mock/apps'
require 'heroku/api/mock/collaborators'
require 'heroku/api/mock/config_vars'
require 'heroku/api/mock/domains'
require 'heroku/api/mock/keys'
require 'heroku/api/mock/logs'
require 'heroku/api/mock/processes'
require 'heroku/api/mock/releases'
require 'heroku/api/mock/stacks'
require 'heroku/api/mock/user'

module Heroku
  class API
    module Mock

      APP_NOT_FOUND  = { :body => 'App not found.',   :status => 404 }
      USER_NOT_FOUND = { :body => 'User not found.',  :status => 404 }

      @mock_data = Hash.new do |hash, key|
        hash[key] = {
          :addons           => {},
          :apps             => [],
          :collaborators    => {},
          :config_vars      => {},
          :domains          => {},
          :keys             => [],
          :maintenance_mode => [],
          :ps               => {},
          :releases         => {},
          :user             => {}
        }
      end

      def self.add_mock_app_addon(mock_data, app, addon)
        addon_data = get_mock_addon(mock_data, addon)
        mock_data[:addons][app] << addon_data.reject {|key, value| !['beta', 'configured', 'description', 'name', 'state', 'url'].include?(key)}
        version = mock_data[:releases][app].map {|release| release['name'][1..-1].to_i}.max || 0
        env = if get_mock_app(mock_data, app)['stack'] == 'cedar'
          {
            'BUNDLE_WITHOUT'      => 'development:test',
            'DATABASE_URL'        => 'postgres://username:password@ec2-123-123-123-123.compute-1.amazonaws.com/username',
            'LANG'                => 'en_US.UTF-8',
            'RACK_ENV'            => 'production',
            'SHARED_DATABASE_URL' => 'postgres://username:password@ec2-123-123-123-123.compute-1.amazonaws.com/username'
          }
        else
          {}
        end
        mock_data[:releases][app] << {
          'addons'      => mock_data[:addons][app].map {|addon| addon['name']},
          'commit'      => nil,
          'created_at'  => timestamp,
          'descr'       => "Add-on add #{addon_data['name']}",
          'env'         => env,
          'name'        => "v#{version + 1}",
          'pstable'     => { 'web' => '' },
          'user'        => 'email@example.com'
        }
      end

      def self.get_mock_addon(mock_data, addon)
        @addons ||= begin
          data = File.read("#{File.dirname(__FILE__)}/mock/cache/get_addons.json")
          Heroku::API::OkJson.decode(data)
        end
        @addons.detect {|addon_data| addon_data['name'] == addon}
      end

      def self.get_mock_addon_price(mock_data, addon)
        addon_data = get_mock_addon(mock_data, addon)
        price_cents = addon_data['price_cents'] || 0
        price = format("$%d/mo", price_cents / 100)
        if price == '$0/mo'
          price = 'free'
        end
        price
      end

      def self.get_mock_app(mock_data, app)
        mock_data[:apps].detect {|app_data| app_data['name'] == app}
      end

      def self.get_mock_app_addon(mock_data, app, addon)
        mock_data[:addons][app].detect {|addon_data| addon_data['name'] == addon}
      end

      def self.get_mock_app_domain(mock_data, app, domain)
        mock_data[:domains][app].detect {|domain_data| domain_data['domain'] == domain}
      end

      def self.get_mock_collaborator(mock_data, app, email)
        mock_data[:collaborators][app].detect {|collaborator_data| collaborator_data['email'] == email}
      end

      def self.get_mock_key(mock_data, key)
        mock_data[:keys].detect {|key_data| %r{ #{Regexp.escape(key)}$}.match(key_data['contents'])}
      end

      def self.get_mock_processes(mock_data, app)
        mock_data[:ps][app].map do |ps|

          # swap day/month positions for Time.parse
          time_parts = ps['transitioned_at'].split(' ')
          date_parts = time_parts.first.split('/')
          date_parts[1], date_parts[2] = date_parts[2], date_parts[1]
          time_parts[0] = date_parts.join('/')
          munged_time = time_parts.join(' ')
          elapsed = Time.now.to_i - Time.parse(munged_time).to_i
          ps['elapsed'] = elapsed

          pretty_elapsed = if elapsed < 60
            "#{elapsed}s"
          elsif elapsed < (60 * 60)
            "#{elapsed / 60}m"
          else
            "#{elapsed / 60 / 60}h"
          end
          ps['pretty_state'] = "#{ps['state']} for #{pretty_elapsed}"

          ps
        end
      end

      def self.gzip(string)
        io = StringIO.new
        gzip = Zlib::GzipWriter.new(io)
        gzip.write(string)
        gzip.close
        io.string
      end

      def self.json_gzip(string)
        gzip(Heroku::API::OkJson.encode(string))
      end

      def self.parse_stub_params(params)
        api_key = Base64.decode64(params[:headers]['Authorization']).split(':').last

        parsed = params.dup
        begin # try to JSON decode
          parsed[:body] &&= Heroku::API::OkJson.decode(parsed[:body])
        rescue # else leave as is
        end

        [parsed, @mock_data[api_key]]
      end

      def self.remove_mock_app_addon(mock_data, app, addon)
        addon_data = mock_data[:addons][app].detect {|addon_data| addon_data['name'] == addon}
        mock_data[:addons][app].delete(addon_data)
        version = mock_data[:releases][app].map {|release| release['name'][1..-1].to_i}.max || 0
        env = if get_mock_app(mock_data, app)['stack'] == 'cedar'
          {
            'BUNDLE_WITHOUT'      => 'development:test',
            'DATABASE_URL'        => 'postgres://username:password@ec2-123-123-123-123.compute-1.amazonaws.com/username',
            'LANG'                => 'en_US.UTF-8',
            'RACK_ENV'            => 'production',
            'SHARED_DATABASE_URL' => 'postgres://username:password@ec2-123-123-123-123.compute-1.amazonaws.com/username'
          }
        else
          {}
        end
        mock_data[:releases][app] << {
          'addons'      => mock_data[:addons][app].map {|addon| addon['name']},
          'commit'      => nil,
          'created_at'  => timestamp,
          'descr'       => "Add-on remove #{addon_data['name']}",
          'env'         => env,
          'name'        => "v#{version + 1}",
          'pstable'     => { 'web' => '' },
          'user'        => 'email@example.com'
        }
      end

      def self.with_mock_app(mock_data, app, &block)
        if app_data = get_mock_app(mock_data, app)
          yield(app_data)
        else
          APP_NOT_FOUND
        end
      end

      def self.timestamp
        Time.now.strftime("%G/%d/%m %H:%M:%S %z")
      end

    end
  end
end
