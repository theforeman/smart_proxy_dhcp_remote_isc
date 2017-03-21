require 'test_helper'
require 'tempfile'

require 'smart_proxy_dhcp_remote_isc/plugin_configuration'
require 'smart_proxy_dhcp_remote_isc/dhcp_remote_isc_plugin'
require 'dhcp_common/subnet_service'
require 'dhcp_common/isc/omapi_provider'
require 'dhcp_common/isc/configuration_file'
require 'smart_proxy_dhcp_remote_isc/file_parser'
require 'smart_proxy_dhcp_remote_isc/subnet_service_initializer'

class ConfigurationTest < ::Test::Unit::TestCase
  def test_default_configuration
    Proxy::DHCP::RemoteISC::Plugin.load_test_settings({})
    assert_equal '7911', Proxy::DHCP::RemoteISC::Plugin.settings.omapi_port
    assert_equal '/etc/dhcp/dhcpd.conf', Proxy::DHCP::RemoteISC::Plugin.settings.config
    assert_equal '/var/lib/dhcpd/dhcpd.leases', Proxy::DHCP::RemoteISC::Plugin.settings.leases
  end
end

class ProductionDiWiringsTest < Test::Unit::TestCase
  def setup
    @settings = {:server => "a_server", :omapi_port => 7911, :key_name => "key_name", :key_secret => "key_secret",
                 :subnets => ["192.168.0.0/255.255.255.0"], :config => Tempfile.new('config').path,
                 :leases => Tempfile.new('leases').path}
    @container = ::Proxy::DependencyInjection::Container.new
    ::Proxy::DHCP::RemoteISC::PluginConfiguration.new.load_dependency_injection_wirings(@container, @settings)
  end

  def test_provider_initialization
    provider = @container.get_dependency(:dhcp_provider)

    assert_equal @settings[:server], provider.name
    assert_equal @settings[:omapi_port], provider.omapi_port
    assert_equal @settings[:key_name], provider.key_name
    assert_equal @settings[:key_secret], provider.key_secret
    assert_equal Set.new(@settings[:subnets]), provider.managed_subnets
    assert_equal ::Proxy::DHCP::SubnetService, provider.service.class
  end

  def test_config_file_initialization
    config_file = @container.get_dependency(:config_file)

    assert_equal @settings[:config], config_file.path
    assert config_file.parser
  end

  def test_parser_initialization
    assert @container.get_dependency(:parser)
  end

  def test_subnet_service_initializer_configuration
    service_initializer = @container.get_dependency(:subnet_service_initializer)

    assert service_initializer
    assert_equal ::Proxy::DHCP::SubnetService, service_initializer.service.class
    assert_equal ::Proxy::DHCP::RemoteISC::IscFileParser, service_initializer.parser.class
    assert_equal ::Proxy::DHCP::IscConfigurationFile, service_initializer.config_file.class
    assert_equal @settings[:leases], service_initializer.leases_path
  end

  def test_initialized_subnet_service
    assert @container.get_dependency(:initialized_subnet_service)
  end
end
