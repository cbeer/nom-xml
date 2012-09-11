# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nom/version"

Gem::Specification.new do |s|
  s.name = "nom"
  s.version = Nom::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Chris Beer"]
  s.email = %q{cabeer@stanford.edu}
  s.homepage = %q{http://github.com/cbeer/nom}
  s.summary = %q{ asdf }
  s.description = %q{ asdfgh }

  s.add_dependency 'nokogiri'

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc",
    "README.textile"
  ]
  s.require_paths = ["lib"]
end
