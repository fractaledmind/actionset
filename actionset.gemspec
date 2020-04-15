# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.platform      = Gem::Platform::RUBY
  spec.name          = 'actionset'
  spec.version       = '0.10.0'
  spec.authors       = ['Stephen Margheim']
  spec.email         = ['stephen.margheim@gmail.com']

  spec.summary       = 'A toolkit for working with collections.'
  spec.description   = 'Easily filter, sort, and paginate collections.'
  spec.homepage      = 'https://github.com/fractaledmind/actionset'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'railties'
end
