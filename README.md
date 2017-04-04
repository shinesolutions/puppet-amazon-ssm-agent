# amz_ssm_agent

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with amazon_ssm_agent](#setup)
    * [Beginning with amazon_ssm_agent](#beginning-with-amz_ssm_agent)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description


Download and install Amazon System Management Agent, i.e., amazon-ssm-agent package.

## Setup

### Beginning with amzaon_ssm_agent -- Installtion
puppet module install shinesolutions/amazon_ssm_agent

## Usage

```
class amazon_ssm_agent
```
or specifying an AWS Region to download the latest package:

```
class amazon_ssm_agent {
  region => 'ap-southeast-2',
}
```

## Reference
### Public classes
amazon_ssm_agent


## Limitations

The module is still under active development and test.
