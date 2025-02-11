# frozen_string_literal: true

require File.expand_path('lib/smart_proxy_dhcp_remote_isc/version', __dir__)

Gem::Specification.new do |s|
  s.name        = 'smart_proxy_dhcp_remote_isc'
  s.version     = Proxy::DHCP::RemoteISC::VERSION
  s.license     = 'GPL-3.0-only'
  s.authors     = ['Dmitri Dolguikh']
  s.email       = ['dmitri@appliedlogic.ca']
  s.homepage    = 'https://github.com/theforeman/smart_proxy_dhcp_remote_isc'

  s.summary     = "Smart-Proxy dhcp module provider for NFS-accessible ISC dhcpd installations"
  s.description = <<~DESC
    For integration with ISC dhcpd by providing the configuration and leases
    over networked storage like NFS.
  DESC

  s.files       = Dir['{config,lib,bundler.d}/**/*'] + ['README.md', 'LICENSE']
  s.test_files  = Dir['test/**/*']

  s.required_ruby_version = '>= 2.7'
end
