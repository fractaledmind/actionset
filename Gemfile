source 'https://rubygems.org'

ruby '>= 2.6'

# Runtime dependencies
gem 'activerecord', '~> 6.0'
gem 'actionpack', '~> 6.0'
gem 'sqlite3', '~> 1.4'

# Gem under test
gem 'actionset', path: '.'

# test/dev dependencies
gem 'gemika', group: [:development, :test]
eval_gemfile './gemfiles/Gemfile.test'
