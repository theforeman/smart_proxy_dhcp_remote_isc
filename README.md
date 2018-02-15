# SmartProxyDhcpRemoteISC

[![Build Status](https://travis-ci.org/theforeman/smart_proxy_dhcp_remote_isc.svg?branch=master)](https://travis-ci.org/theforeman/smart_proxy_dhcp_remote_isc)

This plugin allows to interface with ISC dhcpd servers that have configuration and lease files shared over NFS

## Installation

See [How_to_Install_a_Smart-Proxy_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Smart-Proxy_Plugin)
for how to install Smart Proxy plugins

This plugin is compatible with Smart Proxy 1.15 or higher.

When installing using "gem", make sure to install the bundle file:

    echo "gem 'smart_proxy_dhcp_infoblox'" > /usr/share/foreman-proxy/bundler.d/dhcp_remote_isc.rb

## Configuration

To enable this DHCP provider, edit `/etc/foreman-proxy/settings.d/dhcp.yml` and set:

    :use_provider: dhcp_remote_isc
    :server: IP address of dhcpd server
    :subnets: subnets you want to use (optional unless you set infoblox_subnets to false)

Configuration options are the same as for the core ISC dhcpd provider. Please refer to [Smart Proxy documentation](https://theforeman.org/manuals/1.14/index.html#4.3.4DHCP) for detailed instructions.

## Contributing

Fork and send a Pull Request. Thanks!

## License

Please see [LICENSE](LICENSE) file.
