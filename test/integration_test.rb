require "rack/test"
require 'test_helper'
require 'json'
require 'dhcp_common/dhcp_common'
require 'dhcp_common/subnet_service'
require 'dhcp_common/free_ips'
require 'dhcp_common/isc/omapi_provider'
require 'dhcp_common/isc/configuration_parser'
require 'dhcp_common/isc/subnet_service_initialization'
require 'smart_proxy_dhcp_remote_isc/subnet_service_initializer'
require 'dhcp/dhcp'
require 'dhcp/dependency_injection'
require 'dhcp/dhcp_api'

ENV['RACK_ENV'] = 'test'

class IntegrationTest < ::Test::Unit::TestCase
  include Rack::Test::Methods

  class SubnetServiceInitializerForTesting < Proxy::DHCP::RemoteISC::SubnetServiceInitializer
    def read_leases_file
      return <<EOF
host testing-01 { hardware ethernet 11:22:33:a9:61:09; fixed-address 10.0.0.200; dynamic; }
EOF
    end

    def read_config_file
      return <<EOF
subnet 10.0.0.0 netmask 255.255.255.0 {
}
EOF
    end
  end

  class IscOmapiProviderForTesting < Proxy::DHCP::CommonISC::IscOmapiProvider
    def om
      @om ||= StringIO.new
    end

    def om_disconnect(msg)
      @om = nil
    end
  end

  def app
    app = Proxy::DhcpApi.new
    app.helpers.server = @server
    app
  end

  def setup
    @subnet_service = ::Proxy::DHCP::SubnetService.new(::Proxy::MemoryStore.new, ::Proxy::MemoryStore.new, ::Proxy::MemoryStore.new,
                                                       ::Proxy::MemoryStore.new, ::Proxy::MemoryStore.new)
    @parser = ::Proxy::DHCP::CommonISC::ConfigurationParser.new

    subnet_service_initializer =
      SubnetServiceInitializerForTesting.new("config_path", "leases_path", @parser, @subnet_service)
    @initialized_subnet_service = subnet_service_initializer.initialized_subnet_service

    @free_ips = ::Proxy::DHCP::FreeIps.new(10)

    @server = IscOmapiProviderForTesting.new("127.0.0.1", '7911', [], 'key', 'secret', @initialized_subnet_service, @free_ips)

    @expected_reservation = {"name" => "testing-01", "ip" => "10.0.0.200", "mac" => "11:22:33:a9:61:09",
                             "subnet" => "10.0.0.0/255.255.255.0", "type" => "reservation", "deleteable" => true,
                             "hostname" => "testing-01", "hardware_type" => "ethernet"}
  end


  def test_get_subnets
    get "/"

    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
    parsed_response = JSON.parse(last_response.body)
    assert_equal 1, parsed_response.size
    assert_equal "10.0.0.0", parsed_response.first['network']
    assert_equal "255.255.255.0", parsed_response.first['netmask']
  end

  def test_get_network
    get "/10.0.0.0"

    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
    parsed_response = JSON.parse(last_response.body)
    assert parsed_response.key?('reservations')
    assert_equal 1, parsed_response['reservations'].size
    assert parsed_response.key?('leases')
    assert parsed_response['leases'].empty?
    assert_equal@expected_reservation, parsed_response['reservations'].first
  end

  def test_get_unused_ip
    get "/10.0.0.0/unused_ip"

    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
    parsed_response = JSON.parse(last_response.body)
    assert parsed_response.key?('ip')
  end

  def test_get_records_by_ip
    get "/10.0.0.0/ip/10.0.0.200"
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
    parsed_response = JSON.parse(last_response.body)
    assert_equal 1, parsed_response.size
    assert_equal @expected_reservation, parsed_response.first
  end

  def test_get_record_by_mac
    get "/10.0.0.0/mac/11:22:33:a9:61:09"
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
    assert_equal @expected_reservation, JSON.parse(last_response.body)
  end

  def test_create_record
    record = {
        "hostname" => "test-02",
        "ip"       => "10.0.0.250",
        "mac"      => "10:10:10:10:10:10",
        "network"  => "10.0.0.0",
    }
    post "/10.0.0.0", record
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
  end

  def test_delete_records_by_ip
    delete "/10.0.0.0/ip/10.0.0.200"
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
  end

  def test_delete_record_by_mac
    delete "/10.0.0.0/mac/11:22:33:a9:61:09"
    assert last_response.ok?, "Last response was not ok: #{last_response.status} #{last_response.body}"
  end
end
