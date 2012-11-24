# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "silverpop_client/version"

Gem::Specification.new do |s|
  s.name        = "silverpop_client"
  s.version     = SilverpopClient::VERSION
  s.authors     = ["Arthur Purvis"]
  s.email       = ["apurvis@lumoslabs.com"]
  s.homepage    = "http://www.lumosity.com"
  s.summary     = %q{Provides a ruby interface to the Silverpop Engage 3 XML APIs}
  s.description = %q{Provides a ruby interface to the Silverpop Engage 3 XML APIs}

  s.rubyforge_project = "silverpop_client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"

  s.add_runtime_dependency "hpricot"
  s.add_runtime_dependency "net-sftp"
end
