# frozen_string_literal: true

module Proxy::DHCP::RemoteISC
  class PluginConfiguration
    def load_dependency_injection_wirings(container, settings)
      container.dependency :memory_store, ::Proxy::MemoryStore
      container.dependency :subnet_service, (lambda do
        ::Proxy::DHCP::SubnetService.new(container.get_dependency(:memory_store),
                                         container.get_dependency(:memory_store), container.get_dependency(:memory_store),
                                         container.get_dependency(:memory_store), container.get_dependency(:memory_store))
      end)
      container.dependency :parser, -> { ::Proxy::DHCP::CommonISC::ConfigurationParser.new }
      container.dependency :subnet_service_initializer, (lambda do
        ::Proxy::DHCP::RemoteISC::SubnetServiceInitializer.new(settings[:config], settings[:leases],
                                                               container.get_dependency(:parser), container.get_dependency(:subnet_service))
      end)
      container.dependency :initialized_subnet_service, -> { container.get_dependency(:subnet_service_initializer).initialized_subnet_service }
      container.singleton_dependency :free_ips, -> { ::Proxy::DHCP::FreeIps.new(settings[:blacklist_duration_minutes]) }

      container.dependency :dhcp_provider, (lambda do
        Proxy::DHCP::CommonISC::IscOmapiProvider.new(
          settings[:server], settings[:omapi_port], settings[:subnets], settings[:key_name], settings[:key_secret],
          container.get_dependency(:initialized_subnet_service), container.get_dependency(:free_ips)
        )
      end)
    end

    def load_classes
      require 'dhcp_common/subnet_service'
      require 'dhcp_common/free_ips'
      require 'dhcp_common/isc/omapi_provider'
      require 'dhcp_common/isc/configuration_parser'
      require 'dhcp_common/isc/subnet_service_initialization'
      require 'smart_proxy_dhcp_remote_isc/subnet_service_initializer'
    end
  end
end
