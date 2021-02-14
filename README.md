[![Build Status](https://github.com/shinesolutions/puppet-amazon-ssm-agent/workflows/CI/badge.svg)](https://github.com/shinesolutions/puppet-amazon-ssm-agent/actions?workflow=CI)
[![Published Version](https://img.shields.io/puppetforge/v/shinesolutions/amazon_ssm_agent.svg)](http://forge.puppet.com/shinesolutions/amazon_ssm_agent)
[![Downloads Count](https://img.shields.io/puppetforge/dt/shinesolutions/amazon_ssm_agent.svg)](http://forge.puppet.com/shinesolutions/amazon_ssm_agent)
[![Known Vulnerabilities](https://snyk.io/test/github/shinesolutions/puppet-amazon-ssm-agent/badge.svg)](https://snyk.io/test/github/shinesolutions/puppet-amazon-ssm-agent)

Puppet AEM Resources
--------------------

A Puppet module for provisioning [AWS Systems Manager](https://aws.amazon.com/systems-manager/) agent.

Learn more about Puppet AEM Resources:

* [Installation](https://github.com/shinesolutions/puppet-amazon-ssm-agent#installation)
* [Usage](https://github.com/shinesolutions/puppet-amazon-ssm-agent#usage)
* [Upgrade](https://github.com/shinesolutions/puppet-amazon-ssm-agent#upgrade)
* [Testing](https://github.com/shinesolutions/puppet-amazon-ssm-agent#testing)

Installation
------------

    puppet module install shinesolutions-amazon_ssm_agent

Or via a Puppetfile:

    mod 'shinesolutions/amazon_ssm_agent'

If you want to use the master version:

    mod 'shinesolutions/amazon_ssm_agent', :git => 'https://github.com/shinesolutions/amazon_ssm_agent'

Usage
-----

Provision SSM agent with default region `us-east-1`:

    include amazon_ssm_agent

Provision SSM agent with a custom region:

    class {'amazon_ssm_agent':
      region => 'ap-southeast-2',
    }

Provision SSM agent with proxy configuration:

    class {'amazon_ssm_agent':
      region     => 'ap-southeast-2',
      proxy_host => 'some.proxy.com',
      proxy_port => '3128'
    }
