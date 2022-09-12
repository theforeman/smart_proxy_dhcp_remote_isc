require 'dhcp_common/isc/subnet_service_initialization'

module Proxy::DHCP::RemoteISC
  class SubnetServiceInitializer < ::Proxy::DHCP::CommonISC::IscSubnetServiceInitialization
    include Proxy::Log

    attr_reader :config_file_path, :leases_file_path

    def initialize(config_file_path, leases_file_path, parser, subnet_service)
      @config_file_path = config_file_path
      @leases_file_path = leases_file_path
      super(subnet_service, parser)
    end

    def initialized_subnet_service
      load_configuration_file(read_config_file, config_file_path)
      load_leases_file(read_leases_file, leases_file_path)
      subnet_service
    end

    def read_leases_file
      File.read(File.expand_path(leases_file_path))
    end

    def read_config_file
      File.read(File.expand_path(config_file_path))
    end
  end
end
