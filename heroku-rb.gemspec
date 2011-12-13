# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "heroku-rb/version"

Gem::Specification.new do |s|
  s.name        = "heroku-rb"
  s.version     = Heroku::VERSION
  s.authors     = ["geemus (Wesley Beary)"]
  s.email       = ["wesley@heroku.com"]
  s.homepage    = ""
  s.summary     = %q{Ruby Client for the Heroku API}
  s.description = %q{Ruby Client for the Heroku API}

  s.rubyforge_project = "heroku-rb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency 'excon'
end
