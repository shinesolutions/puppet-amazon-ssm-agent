# Class: amazon_ssm_agent
# ===========================
#
# Download and install Amazon System Management Agent, amazon-ssm-agent.
#
# Parameters
# ----------
#
# * `region`
# Data Type: String
# The AWS region from where the package will be downloaded
# Default value: us-east-1
#
# * `proxy_url`
# Data Type: String
# The proxy URL in <protocol>://<host>:<port> format, specify if the ssm agent needs to communicate via a proxy
# Default value: undef
#
#
# Examples
# --------
# @example
#    class { 'amazon_ssm_agent':
#      region    => 'ap-southeast-2',
#      proxy_url => 'http://someproxy:3128',
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
# Copyright 2017 Shine Solutions, unless otherwise noted.
#
class amazon_ssm_agent (
  $region    = 'us-east-1',
  $proxy_url = undef,
  ) {

    $pkg_provider = lookup('amazon_ssm_agent::pkg_provider', String, 'first')
    $pkg_format   = lookup('amazon_ssm_agent::pkg_format', String, 'first')
    $flavor       = lookup('amazon_ssm_agent::flavor', String, 'first')

    $srv_provider = lookup('amazon_ssm_agent::srv_provider', String, 'first')

    case $facts['os']['architecture'] {
      'x86_64','amd64': {
        $architecture = 'amd64'
      }
      'i386': {
        $architecture = '386'
      }
      default: {
        fail("Module not supported on ${facts['os']['architecture']} architecture")
      }
    }

    archive {"/tmp/amazon-ssm-agent.${pkg_format}":
      ensure  => present,
      extract => false,
      cleanup => false,
      source  => "https://amazon-ssm-${region}.s3.amazonaws.com/latest/${flavor}_${architecture}/amazon-ssm-agent.${pkg_format}",
      creates => "/tmp/amazon-ssm-agent.${pkg_format}",
    } -> package { 'amazon-ssm-agent':
      ensure   => latest,
      provider => $pkg_provider,
      source   => "/tmp/amazon-ssm-agent.${pkg_format}",
    }

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
          }
        }
        ini_setting { "Set no_proxy configuration with status ${status}":
          ensure            => $status,
          path              => $config_file,
          section           => 'Service',
          setting           => "Environment=\"no_proxy",
          value             => "169.254.169.254\"",
          key_val_separator => '=',
        }
      }
      default: {
        fail("Module does not support ${srv_provider} service provider")
      }
    }

    service { 'amazon-ssm-agent':
      ensure    => running,
      enable    => true,
      provider  => $srv_provider,
      subscribe => File_line['no_proxy']
    }

    file {"/tmp/amazon-ssm-agent.${pkg_format}":
      ensure  => absent,
      require => Package['amazon-ssm-agent'],
    }
}
