module Proxy::DHCP::RemoteISC
  class Plugin < ::Proxy::Provider
    plugin :dhcp_remote_isc, ::Proxy::DHCP::RemoteISC::VERSION

    requires :dhcp, '>= 1.15'
    default_settings :config => '/etc/dhcp/dhcpd.conf', :leases => '/var/lib/dhcpd/dhcpd.leases',
                     :omapi_port => '7911'

    validate_readable :config, :leases

    load_classes ::Proxy::DHCP::RemoteISC::PluginConfiguration
    load_dependency_injection_wirings ::Proxy::DHCP::RemoteISC::PluginConfiguration
  end
end
