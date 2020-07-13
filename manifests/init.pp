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
# Copyright 2017-2019 Shine Solutions, unless otherwise noted.
#
class amazon_ssm_agent (
  $region    = 'us-east-1',
  $proxy_url = undef,
  ) {

    $pkg_provider = lookup('amazon_ssm_agent::pkg_provider', String, 'first')
    $pkg_format   = lookup('amazon_ssm_agent::pkg_format', String, 'first')
    $flavor       = lookup('amazon_ssm_agent::flavor', String, 'first')

    # hardcoded to avoid error with failing to use upstart
    $srv_provider = 'systemd'

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

    class { '::amazon_ssm_agent::proxy':
      proxy_url    => $proxy_url,
      srv_provider => $srv_provider,
      require      => Package['amazon-ssm-agent'],
      before       => Service['amazon-ssm-agent'],
    }

    service { 'amazon-ssm-agent':
      ensure   => running,
      enable   => true,
      provider => $srv_provider,
    }

    file {"/tmp/amazon-ssm-agent.${pkg_format}":
      ensure  => absent,
      require => Package['amazon-ssm-agent'],
    }
}
