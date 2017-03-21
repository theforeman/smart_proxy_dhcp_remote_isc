module Proxy::DHCP::RemoteISC
  class PluginConfiguration
    def load_dependency_injection_wirings(container, settings)
      container.dependency :memory_store, ::Proxy::MemoryStore
      container.dependency :subnet_service, (lambda do
        ::Proxy::DHCP::SubnetService.new(container.get_dependency(:memory_store),
                                         container.get_dependency(:memory_store), container.get_dependency(:memory_store),
                                         container.get_dependency(:memory_store), container.get_dependency(:memory_store))
      end)
      container.dependency :parser, lambda {::Proxy::DHCP::RemoteISC::IscFileParser.new}
      container.dependency :config_file, lambda {::Proxy::DHCP::IscConfigurationFile.new(settings[:config], container.get_dependency(:parser))}
      container.dependency :subnet_service_initializer, (lambda do
        ::Proxy::DHCP::RemoteISC::SubnetServiceInitializer.new(container.get_dependency(:config_file), settings[:leases],
                                                               container.get_dependency(:parser), container.get_dependency(:subnet_service))
      end)
      container.dependency :initialized_subnet_service, lambda {container.get_dependency(:subnet_service_initializer).initialized_subnet_service }

      container.dependency :dhcp_provider, (lambda do
        Proxy::DHCP::IscOmapiProvider.new(
            settings[:server], settings[:omapi_port], settings[:subnets], settings[:key_name], settings[:key_secret],
            container.get_dependency(:initialized_subnet_service))
      end)
    end

    def load_classes
      require 'dhcp_common/subnet_service'
      require 'dhcp_common/isc/omapi_provider'
      require 'dhcp_common/isc/configuration_file'
      require 'smart_proxy_dhcp_remote_isc/file_parser'
      require 'smart_proxy_dhcp_remote_isc/subnet_service_initializer'
    end
  end
end
