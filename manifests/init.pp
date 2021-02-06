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
# * `service_enable`
# Data Type: Boolean
# Ensure state of the service. Can be 'running', 'stopped', true, or false
# Default value: 'running'
#
# * `service_ensure`
# Data Type: String, Boolean
# Whether to enable the service.
# Default value: true
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
# Copyright 2017-2019 Shine Solutions, unless otherwise noted.
#
class amazon_ssm_agent (
  String $region              = 'us-east-1',
  Optional[String] $proxy_url = undef,
  Boolean $service_enable     = true,
  $service_ensure             = 'running',
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
      'aarch64','arm64': {
        $architecture = 'arm64'
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

    if $service_ensure {
      class { '::amazon_ssm_agent::proxy':
        proxy_url    => $proxy_url,
        srv_provider => $srv_provider,
        require      => Package['amazon-ssm-agent'],
      }

      service { 'amazon-ssm-agent':
        ensure   => $service_ensure,
        enable   => $service_enable,
        provider => $srv_provider,
      }

      Class['::amazon_ssm_agent::proxy'] -> Service['amazon-ssm-agent']
    }

    file {"/tmp/amazon-ssm-agent.${pkg_format}":
      ensure  => absent,
      require => Package['amazon-ssm-agent'],
    }
}
