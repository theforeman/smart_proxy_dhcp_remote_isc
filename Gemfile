source 'https://rubygems.org'
gemspec

group :development do
  if RUBY_VERSION < '1.9.3'
    gem 'rake', '< 11'
  else
    gem 'rake'
    gem 'test-unit'
  end
  gem 'mocha'
  #gem 'smart_proxy', :github => 'theforeman/smart-proxy', :branch => 'develop'
  gem 'smart_proxy', :path => '/home/wb/sandbox/smart-proxy', :branch => 'common-isc-bits'
end