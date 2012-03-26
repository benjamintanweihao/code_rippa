# -*- encoding: utf-8 -*-
require File.expand_path('../lib/code_rippa/version', __FILE__)
require File.expand_path('../lib/code_rippa/uv_overrides', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Benjamin Tan Wei Hao"]
  gem.email         = ["ben@witsvale.com"]
  gem.platform      = Gem::Platform::RUBY
  gem.description   = %q{Converts source code into a (bookmarked, themed, and syntax highlighted!) PDF.}
  gem.summary       = %q{Converts source code into a (bookmarked, themed, and syntax highlighted!) PDF. Supports 150 languages and Textmate themes. }
  gem.homepage      = "http://code-rippa.heroku.com"
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  # gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "code_rippa"
  gem.require_paths = ["lib"]
  gem.version       = CodeRippa::VERSION
  gem.required_ruby_version = '>= 1.9.0'
  gem.add_dependency "spox-ultraviolet", "~> 0.10.5"
end
