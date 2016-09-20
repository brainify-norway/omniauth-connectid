# -*- encoding: utf-8 -*-
require File.expand_path(File.join('..', 'lib', 'omniauth', 'connectid', 'version'), __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "omniauth-connectid"
  gem.version       = OmniAuth::Connectid::VERSION
  gem.license       = 'MIT'
  gem.summary       = %q{A Connect ID strategy for OmniAuth 1.x}
  gem.description   = %q{A Connect ID strategy for OmniAuth 1.x}
  gem.authors       = ["Gunnar Fornes"]
  gem.email         = ["gunnar@brainify.no"]
  gem.homepage      = "https://github.com/brainify-norway/omniauth-connectid"

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 2.0'

  gem.add_runtime_dependency 'omniauth', '>= 1.1.1'
  gem.add_runtime_dependency 'omniauth-oauth2', '~> 1.3.1'
  gem.add_runtime_dependency 'jwt', '~> 1.5.2'
  gem.add_runtime_dependency 'multi_json', '~> 1.3'

  gem.add_development_dependency 'rspec', '>= 2.14.0'
  gem.add_development_dependency 'rake'
end
