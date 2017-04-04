# Class: amz_ssm_agent
# ===========================
#
# Download and install Amazon System Management Agent, amazon-ssm-agent.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `region`
#  The AWS region from where the package will be downloaded
#
# Examples
# --------
#
# @example
#    class { 'amz_ssm_agent':
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
  ) {

    $pkg_provider = lookup('amazon_ssm_agent::pkg_provider', String, 'first')
    $pkg_format   = lookup('amazon_ssm_agent::pkg_format', String, 'first')
    $flavor       = lookup('amazon_ssm_agent::flavor', String, 'first')

    $srv_provider = lookup('amazon_ssm_agent::srv_provider', String, 'first')

    case $facts['architecture'] {
      'x86_64': {
        $architecture = 'amd64'
      }
      'i386': {
        $architecture = '386'
      }
      default: {
        fail("Module not support on ${facts['architecture']}")
      }
    }

    package { 'amazon-ssm-agent':
      ensure   => latest,
      provider => $pkg_provider,
      source   => "https://s3.${region}.amazonaws.com/amazon-ssm-${region}/latest/${flavor}_${architecture}/amazon-ssm-agent.${pkg_format}",
    } ~>
    service { 'amazon-ssm-agent':
      ensure   => running,
      enable   => true,
      provider => $srv_provider,
    }

}
