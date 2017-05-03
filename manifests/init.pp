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
# * `proxy_host`
# Data Type: String
# The name of the proxy host if the ssm agent needs to communicate via a proxy
# Default value: undef
#
# * `proxy_port`
# Data Type: String
# The port number of the proxy host if the ssm agent needs to communicate via a proxy
# Default value: 443
#
# Examples
# --------
# @example
#    class { 'amazon_ssm_agent':
#      region => 'ap-southeast-2',
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
  $region   = 'us-east-1',
  $proxy_host   = undef,
  $proxy_port   = '443',
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
        fail("Module not supported on ${facts['os']['architecture']}")
      }
    }

    archive {"/tmp/amazon-ssm-agent.${pkg_format}":
      ensure  => present,
      extract => false,
      cleanup => false,
      source  => "https://amazon-ssm-${region}.s3.amazonaws.com/latest/${flavor}_${architecture}/amazon-ssm-agent.${pkg_format}",
      creates => "/tmp/amazon-ssm-agent.${pkg_format}",
    }
    -> package { 'amazon-ssm-agent':
      ensure   => latest,
      provider => $pkg_provider,
      source   => "/tmp/amazon-ssm-agent.${pkg_format}",
    }


    case $srv_provider {
      'upstart': {
        $config_file = '/etc/init/amazon-ssm-agent.conf'
        $proxy_line = "env http_proxy=http://${proxy_host}:${proxy_port}"
        $match_expr = '^env http_proxy=.*$'
        $no_proxy_line = 'env no_proxy=169.254.169.254'
      }
      'systemd': {
        $config_file = '/etc/systemd/system/amazon-ssm-agent.service'
        $proxy_line = "Environment=\"HTTP_PROXY=http://${proxy_host}:${proxy_port}\""
        $match_expr = '^Environment=\"HTTP_PROXY=.*$'
        $no_proxy_line = 'Environment="no_proxy=169.254.169.254"'
      }
      default: {
        fail("Module does not support ${srv_provider} service provider")
      }
    }

    if $proxy_host {
      file_line { 'proxy':
        ensure  => present,
        path    => $config_file,
        line    => $proxy_line,
        match   => $match_expr,
        replace => true,
        require => Package['amazon-ssm-agent'],
      }
      -> file_line {'no_proxy':
        ensure => present,
        path   => $config_file,
        line   => $no_proxy_line,
      }
    }
    else {
      file_line {'proxy':
        ensure            => absent,
        path              => $config_file,
        match             => $match_expr,
        match_for_absence => true,
        require           => Package['amazon-ssm-agent']
      }
      -> file_line {'no_proxy':
        ensure => absent,
        path   => $config_file,
        line   => $no_proxy_line,
      }
    }

    service { 'amazon-ssm-agent':
      ensure    => running,
      enable    => true,
      provider  => $srv_provider,
      subscribe => File_line['proxy']
    }

    file {"/tmp/amazon-ssm-agent.${pkg_format}":
      ensure  => absent,
      require => Package['amazon-ssm-agent'],
    }
}
