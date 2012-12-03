# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nom/xml/version"

Gem::Specification.new do |s|
  s.name = "nom-xml"
  s.version = Nom::XML::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Chris Beer", "Michael B. Klein"]
  s.email = %q{cabeer@stanford.edu mbklein@gmail.com}
  s.homepage = %q{http://github.com/cbeer/nom}
  s.summary = %q{ asdf }
  s.description = %q{ asdfgh }

  s.add_dependency 'activesupport'
  s.add_dependency 'i18n'
  s.add_dependency 'nokogiri'

  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"
  s.add_development_dependency "yard"
  s.add_development_dependency "equivalent-xml"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.require_paths = ["lib"]
end
