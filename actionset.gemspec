# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'actionset/version'

Gem::Specification.new do |spec|
  spec.name          = 'actionset'
  spec.version       = Actionset::VERSION
  spec.authors       = ['Stephen Margheim']
  spec.email         = ['margheim@mail.med.upenn.edu']

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

  spec.add_dependency 'activeset'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
