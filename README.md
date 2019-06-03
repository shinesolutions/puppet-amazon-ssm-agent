[![Build Status](https://img.shields.io/travis/shinesolutions/puppet-amazon-ssm-agent.svg)](http://travis-ci.org/shinesolutions/puppet-amazon-ssm-agent)
[![Published Version](https://img.shields.io/puppetforge/v/shinesolutions/amazon_ssm_agent.svg)](http://forge.puppet.com/shinesolutions/amazon_ssm_agent)
[![Downloads Count](https://img.shields.io/puppetforge/dt/shinesolutions/amazon_ssm_agent.svg)](http://forge.puppet.com/shinesolutions/amazon_ssm_agent)
[![Known Vulnerabilities](https://snyk.io/test/github/shinesolutions/puppet-amazon-ssm-agent/badge.svg)](https://snyk.io/test/github/shinesolutions/puppet-amazon-ssm-agent)

# Puppet Amazon SSM Agent

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with amazon_ssm_agent](#setup)
    * [Beginning with amazon_ssm_agent](#beginning-with-amazon_ssm_agent)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Download and install Amazon System Management Agent, i.e., amazon-ssm-agent package.

## Setup

### Beginning with amazaon_ssm_agent -- Installation
put the following line in your Puppetfile
```
mod 'shinesolutions/amazon_ssm_agent', :git => 'https://github.com/shinesolutions/amazon_ssm_agent.git'
```

## Usage
For the simplest scenario, the following will download and install the latest package:
```
include amazon_ssm_agent
```
or specifying an AWS Region that is closest to you:

```
class {'amazon_ssm_agent':
  region => 'ap-southeast-2',
}
```

When the ssm agent has to communicate with Amazon EC2 System Manager Service via a proxy.
```
class {'amazon_ssm_agent':
  region     => 'ap-southeast-2',
  proxy_host => 'proxy.shinesolutions.com',
  proxy_port => '443'
}
```

## Reference
### Public classes
amazon_ssm_agent


## Limitations

The module is still under active development and test. Currently there are no plan to support
platforms other than Amazon Linux, RedHat, CentOS, and Ubuntu.
