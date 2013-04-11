# -*- encoding: utf-8 -*-

#############################################################################################
#  Copyright 2013 Lumos Labs                                                                #
#                                                                                           #
#  This file is part of Lumos Labs Silverpop Client.                                        #
#                                                                                           #
#  Lumos Labs Silverpop Client is free software: you can redistribute it and/or modify      #
#  it under the terms of the GNU General Public License as published by                     #
#  the Free Software Foundation, either version 3 of the License, or                        #
#  (at your option) any later version.                                                      #
#                                                                                           #
#  Lumos Labs Silverpop Client is distributed in the hope that it will be useful,           #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of                           #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                            #
#  GNU General Public License for more details.                                             #
#                                                                                           #
#  You should have received a copy of the GNU General Public License                        #
#  along with Lumos Labs Silverpop Client.  If not, see <http://www.gnu.org/licenses/>.     #
#############################################################################################

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
