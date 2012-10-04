# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'curp'

Gem::Specification.new do |s|
  s.name        = "curp"
  s.version     = Curp::VERSION
  s.authors     = ["Michael King"]
  s.email       = ["mking@enova.com"]
  s.homepage    = ""
  s.summary     = %q{Create and verify CURP numbers}
  s.description = %q{Create and verify CURP numbers}

  s.rubyforge_project = "curp"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
