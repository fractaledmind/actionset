# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'action_set/version'

Gem::Specification.new do |spec|
  spec.name          = 'actionset'
  spec.version       = ActionSet::VERSION
  spec.authors       = ['Stephen Margheim']
  spec.email         = ['stephen.margheim@gmail.com']

  spec.summary       = 'A toolkit to wire-up ActiveSet collections with a Rails controller.'
  spec.description   = 'Easily filter, sort, and paginate enumerable sets via web requests.'
  spec.homepage      = 'https://github.com/fractaledmind/actionset'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activeset', '~> 0.4.0'
  spec.add_dependency 'activesupport', '>= 4.0.2'
  spec.add_dependency 'railties'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.6'
  spec.add_development_dependency 'database_cleaner', '~> 1.6.1'
  spec.add_development_dependency 'capybara', '~> 2.15.1'
  spec.add_development_dependency 'combustion', '~> 0.7.0'
  spec.add_development_dependency 'factory_girl', '~> 4.8.0'
  spec.add_development_dependency 'faker', '~> 1.8.4'
  spec.add_development_dependency 'simplecov', '~> 0.15.0'
  spec.add_development_dependency 'simplecov-console', '~> 0.4.2'
end
