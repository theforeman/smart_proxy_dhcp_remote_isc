# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

group :rubocop do
  gem 'rubocop', '~> 1.28.0'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
end

group :test do
  gem 'ci_reporter_test_unit'
  gem 'concurrent-ruby', '~> 1.0', require: 'concurrent'
  gem 'mocha'
  gem 'rack-test'
  gem 'rake'
  gem 'rsec', '< 1'
  gem 'smart_proxy', :github => 'theforeman/smart-proxy', :branch => 'develop'
  gem 'test-unit'
end
