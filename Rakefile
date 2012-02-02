require "bundler/gem_tasks"

require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |task|
  task.name = :test
  task.test_files = FileList['test/test*.rb']
end

task :cache, [:api_key] do |task, args|
  unless args.api_key
    puts('cache requires an api key, please call as `cache[api_key]`')
  else
    require "#{File.dirname(__FILE__)}/lib/heroku/api"
    heroku = Heroku.new(:api_key => args.api_key)
    data = Heroku::OkJson.encode(heroku.get_addons.body)
    File.open("#{File.dirname(__FILE__)}/lib/heroku/stubs/cache/get_addons.json", 'w') do |file|
      file.write(data)
    end
  end
end
