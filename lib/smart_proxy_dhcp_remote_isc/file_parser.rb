require 'dhcp_common/isc/file_parser'

module ::Proxy::DHCP::RemoteISC
  class IscFileParser < ::Proxy::DHCP::CommonISC::IscFileParser
    def initialize
      super(nil)
    end

    def parse_config_and_leases_for_records(subnet_service, conf)
      @service = subnet_service
      super(conf)
    end
  end
end
