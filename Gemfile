source 'https://rubygems.org'
gemspec

group :development do
  if RUBY_VERSION < '1.9.3'
    gem 'rake', '< 11'
  else
    gem 'rake'
    gem 'test-unit'
  end
  gem 'concurrent-ruby', '~> 1.0', require: 'concurrent'
  gem 'mocha'
  gem 'smart_proxy', :github => 'theforeman/smart-proxy', :branch => 'develop'
end
