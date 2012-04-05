# -*- encoding: utf-8 -*-
require File.expand_path('../lib/code_rippa/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Benjamin Tan Wei Hao"]
  gem.email         = ["ben@witsvale.com"]
  gem.platform      = Gem::Platform::RUBY
  gem.description   = %q{Converts source code into a (bookmarked, themed, and syntax highlighted!) PDF.}
  gem.summary       = %q{CodeRippa takes your source code and turns it into a beautiful PDF file. Currently, it supports 150 languages and 15 themes, all of which are available in TextMate. More syntaxes and themes will be available soon.}
  gem.homepage      = "http://code-rippa.heroku.com"
  gem.has_rdoc      = false
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test)/})
  gem.name          = "code_rippa"
  gem.require_paths = ["lib", "lib/syntax", "lib/render"]
  gem.version       = CodeRippa::VERSION
  gem.required_ruby_version = '>= 1.9.0'
  gem.add_dependency "color"  
  gem.add_dependency "ansi"  
  gem.add_dependency "language_sniffer"  
  gem.add_dependency "ptools", "~> 1.2.1"
  gem.add_dependency "rainbow"
  gem.add_dependency "spox-ultraviolet", "~> 0.10.5"
  gem.add_development_dependency "rake"  
  gem.add_development_dependency "minitest"  
end
