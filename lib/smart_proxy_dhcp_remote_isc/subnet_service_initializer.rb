require 'dhcp_common/isc/subnet_service_initialization'

module Proxy::DHCP::RemoteISC
  class SubnetServiceInitializer
    include ::Proxy::DHCP::CommonISC::IscSubnetServiceInitialization
    include Proxy::Log

    attr_reader :config_file, :leases_path, :parser, :service

    def initialize(config_file, leases_file_path, isc_config_file_parser, subnet_service)
      @config_file = config_file
      @leases_path = leases_file_path
      @parser = isc_config_file_parser
      @service = subnet_service
    end

    def initialized_subnet_service
      load_subnets

      update_subnet_service_with_dhcp_records(hosts_and_leases_from_config(service, config_file))
      update_subnet_service_with_dhcp_records(hosts_and_leases_from_leases(service, leases_path))

      service
    end

    def load_subnets
      service.add_subnets(*config_file.subnets)
    end

    def hosts_and_leases_from_config(subnet_service, config_file)
      parser.parse_config_and_leases_for_records(subnet_service, config_file.read)
    end

    def hosts_and_leases_from_leases(subnet_service, path)
      fd = File.open(File.expand_path(path), "r")
      parser.parse_config_and_leases_for_records(subnet_service, fd.read)
    ensure
      fd.close unless fd.nil?
    end
  end
end

