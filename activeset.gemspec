# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.platform      = Gem::Platform::RUBY
  spec.name          = 'activeset'
  spec.version       = '0.8.1'
  spec.authors       = ['Stephen Margheim']
  spec.email         = ['stephen.margheim@gmail.com']

  spec.summary       = 'A toolkit for working with enumerable sets.'
  spec.description   = 'Easily filter, sort, and paginate enumerable sets.'
  spec.homepage      = 'https://github.com/fractaledmind/activeset'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 4.0.2'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'combustion', '~> 0.7.0'
  spec.add_development_dependency 'database_cleaner', '~> 1.6.1'
  spec.add_development_dependency 'factory_bot', '~> 4.8.0'
  spec.add_development_dependency 'faker', '~> 1.8.4'
  spec.add_development_dependency 'rails', '~> 5.1.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov', '~> 0.15.0'
  spec.add_development_dependency 'simplecov-console', '~> 0.4.2'
end
