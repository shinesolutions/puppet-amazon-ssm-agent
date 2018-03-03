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
function amazon_ssm_agent::get_proxy_line(String $srv_provider, String $key, String $value) {

  case $srv_provider {
    'upstart': {
      "env ${key}=${value}"
    }
    'systemd': {
      "Environment=\"${key}=${value}\""
    }
    default: {
      fail("Module not supported on ${srv_provider} service")
    }
  }
}

function amazon_ssm_agent::get_proxy_match(String $srv_provider, String $key) {

  case $srv_provider {
    'upstart': {
      "^env ${key}=.*$"
    }
    'systemd': {
      "^Environment=\"${key}=.*$"
    }
    default: {
      fail("Module not supported on ${srv_provider} service")
    }
  }
}

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

    case $srv_provider {
      'upstart': {
        $config_file = '/etc/init/amazon-ssm-agent.conf'
      }
      'systemd': {
        $config_file = '/etc/systemd/system/amazon-ssm-agent.service'
      }
      default: {
        fail("Module does not support ${srv_provider} service provider")
      }
    }

    $proxy_env_vars = [ 'http_proxy', 'https_proxy', 'HTTP_PROXY', 'HTTPS_PROXY' ]

    if $proxy_url {
      $proxy_env_vars.each |Integer $index, String $proxy_env_var| {
        file_line { "proxy - ${proxy_env_var}":
          ensure  => present,
          path    => $config_file,
          line    => amazon_ssm_agent::get_proxy_line($srv_provider, $proxy_env_var, $proxy_url),
          match   => amazon_ssm_agent::get_proxy_match($srv_provider, $proxy_env_var),
          replace => true,
          require => Package['amazon-ssm-agent'],
        }
      }
      file_line { 'no_proxy':
        ensure => present,
        path   => $config_file,
        line   => amazon_ssm_agent::get_proxy_line($srv_provider, 'no_proxy', '169.254.169.254'),
      }
    }
    else {
      $proxy_env_vars.each |Integer $index, String $proxy_env_var| {
        file_line { "proxy - ${proxy_env_var}":
          ensure            => absent,
          path              => $config_file,
          match             => amazon_ssm_agent::get_proxy_match($srv_provider, $proxy_env_var),
          match_for_absence => true,
          require           => Package['amazon-ssm-agent'],
        }
      }
      file_line { 'no_proxy':
        ensure => absent,
        path   => $config_file,
        line   => amazon_ssm_agent::get_proxy_line($srv_provider, 'no_proxy', '169.254.169.254'),
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
