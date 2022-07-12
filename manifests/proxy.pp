# Class: amazon_ssm_agent
# ===========================
#
# Configure amazon-ssm-agent proxy settings
#
# Parameters
# ----------
##
# * `proxy_url`
# Data Type: String
# The proxy URL in <protocol>://<host>:<port> format, specify if the ssm agent needs to communicate via a proxy
# Default value: undef
#
# * `srv_provider`
# Data Type: srv_provider
# The name of the service provider
#
#
# Examples
# --------
# @example
#    class { '::amazon_ssm_agent::proxy':
#      proxy_url    => 'http://someproxy:3128',
#      srv_provider => 'systemd'
#    }
#
# Authors
# -------
#
# Andy Wang <andy.wang@shinesolutions.com>
#
# Copyright
# ---------
#
# Copyright 2017-2019 Shine Solutions, unless otherwise noted.
#
class amazon_ssm_agent::proxy (
  $proxy_url    = undef,
  $srv_provider = lookup('amazon_ssm_agent::srv_provider', String, 'first'),
  ) {
    $proxy_env_vars = [ 'http_proxy', 'https_proxy', 'HTTP_PROXY', 'HTTPS_PROXY' ]

    case $srv_provider {
      'upstart': {
        $config_file = '/etc/init/amazon-ssm-agent.conf'
        fail("Module support for ${srv_provider} service provider has been temporarily disabled")
      }
      'systemd': {
        $config_file = '/etc/systemd/system/amazon-ssm-agent.service'
        if $proxy_url {
          $status = present
        } else {
          $status = absent
        }
        # Since puppetlabs/inifile module doesn't support repeat setting,
        # we have to trick it into thinking that the setting includes the env var.
        # Once puppetlabs/inifile supports repeat setting, it can be reverted back
        # to 'Environment'
        $proxy_env_vars.each |Integer $index, String $proxy_env_var| {
          ini_setting { "Set proxy configuration ${proxy_env_var} with status ${status}":
            ensure            => $status,
            path              => $config_file,
            section           => 'Service',
            setting           => "Environment=\"${proxy_env_var}",
            value             => "${proxy_url}\"",
            key_val_separator => '=',
            before            => Service['amazon-ssm-agent'],
          }
        }
        ini_setting { "Set no_proxy configuration with status ${status}":
          ensure            => $status,
          path              => $config_file,
          section           => 'Service',
          setting           => "Environment=\"no_proxy",
          value             => "169.254.169.254,127.0.0.1,localhost\"",
          key_val_separator => '=',
          before            => Service['amazon-ssm-agent'],
        }
      }
      'none': {}
      default: {
        fail("Module does not support ${srv_provider} service provider")
      }
  }
}
