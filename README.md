[![Build Status](https://github.com/shinesolutions/puppet-amazon-ssm-agent/workflows/CI/badge.svg)](https://github.com/shinesolutions/puppet-amazon-ssm-agent/actions?query=workflow%3ACI)
[![Published Version](https://img.shields.io/puppetforge/v/shinesolutions/amazon_ssm_agent.svg)](http://forge.puppet.com/shinesolutions/amazon_ssm_agent)
[![Downloads Count](https://img.shields.io/puppetforge/dt/shinesolutions/amazon_ssm_agent.svg)](http://forge.puppet.com/shinesolutions/amazon_ssm_agent)

# shinesolutions-amazon_ssm_agent

A Puppet module for provisioning the [AWS Systems Manager](https://aws.amazon.com/systems-manager/)
agent: it installs the latest `amazon-ssm-agent` package from AWS's S3 bucket,
optionally sets a proxy for it, and runs it as a systemd service.

Learn more about this module:

* [Installation](#installation)
* [Usage](#usage)
* [Result Model](#result-model)
* [Error Handling](#error-handling)
* [Known Issues](#known-issues)
* [Testing](#testing)
* [Versions History](#versions-history)

## Installation

Requirements:

* Puppet or OpenVox 7, 8 or 9
* Amazon Linux 2023 or Rocky Linux 10, on x86_64 or aarch64
* HTTPS access to `amazon-ssm-<region>.s3.amazonaws.com`, to download the package
* The [puppet/archive](https://forge.puppet.com/modules/puppet/archive) and
  [puppetlabs/inifile](https://forge.puppet.com/modules/puppetlabs/inifile)
  modules, installed automatically as dependencies

Install the module using the `puppet` command:

    puppet module install shinesolutions-amazon_ssm_agent

Or via a Puppetfile:

    mod 'shinesolutions-amazon_ssm_agent'

Or if you want to use the newest code from git:

    mod 'shinesolutions-amazon_ssm_agent', :git => 'https://github.com/shinesolutions/puppet-amazon-ssm-agent'

## Usage

Provision the SSM agent from the default region `us-east-1`:

    include amazon_ssm_agent

Provision the SSM agent from a custom region:

    class { 'amazon_ssm_agent':
      region => 'ap-southeast-2',
    }

Provision the SSM agent with a proxy:

    class { 'amazon_ssm_agent':
      region    => 'ap-southeast-2',
      proxy_url => 'http://someproxy:3128',
    }

| Parameter | Default | Description |
| --- | --- | --- |
| `region` | `us-east-1` | The AWS region whose S3 bucket the package is downloaded from |
| `proxy_url` | `undef` | The proxy URL in `<protocol>://<host>:<port>` format, if the agent needs a proxy |
| `service_ensure` | `running` | The state of the service: `running`, `stopped`, `true` or `false`. With `false`, the proxy and the service aren't managed |
| `service_enable` | `true` | Whether the service starts at boot |

The service provider comes from the module's Hiera data (`amazon_ssm_agent::srv_provider`),
which is `systemd` on Amazon Linux 2023 and Rocky Linux 10.

## Result Model

With the default parameters, applying `amazon_ssm_agent` results in:

| Resource | Default |
| --- | --- |
| Package | `amazon-ssm-agent`, upgraded at each run to the latest package from `https://amazon-ssm-<region>.s3.amazonaws.com/latest/linux_<amd64\|arm64>/amazon-ssm-agent.rpm`, installed with `rpm` |
| Download | `/tmp/amazon-ssm-agent.rpm`, removed again once the package is installed |
| systemd unit | `/etc/systemd/system/amazon-ssm-agent.service`, installed by the package. Its `[Service]` section has the proxy settings below when `proxy_url` is set |
| Proxy settings | `Environment=` lines for `http_proxy`, `https_proxy`, `HTTP_PROXY` and `HTTPS_PROXY` set to `proxy_url`, and `no_proxy` set to `169.254.169.254,127.0.0.1,localhost` (see [Known Issues](#known-issues)) |
| Service | `amazon-ssm-agent`, running and enabled at boot |

## Error Handling

The Puppet run fails when:

* The architecture isn't x86_64, amd64, i386, aarch64 or arm64.
* The service provider is `upstart` (the module's default for RedHat family
  releases without their own Hiera data), or isn't `systemd` or `none`.
* The package can't be downloaded from S3, e.g. without direct internet access:
  the download doesn't use `proxy_url`.

Puppet only checks that the service has started. Without an identity (EC2
instance metadata or an on-premises registration), the agent exits a few
seconds after starting with `failed to find agent identity`, and systemd
restarts it every 90 seconds; its log is in `/var/log/amazon/ssm/`.

## Known Issues

Found while upgrading to OpenVox 9 on Amazon Linux 2023:

* **Amazon Linux 2023 already ships the agent.** Its AMIs install
  `amazon-ssm-agent` from the Amazon Linux repository (3.3.5226.0-1.amzn2023 in
  October 2026), enabled and running, with its unit in
  `/usr/lib/systemd/system`. The module upgrades it to the S3 package (3.3.5538.0
  at the same time), whose unit is `/etc/systemd/system/amazon-ssm-agent.service`.
  A later `dnf upgrade` can bring back the Amazon Linux package if its version is
  higher; that package doesn't have the unit file in `/etc` with the proxy
  settings.
* **The proxy is set by editing the unit file.** This only works while the S3
  package is installed. Without it, the module would create
  `/etc/systemd/system/amazon-ssm-agent.service` with only the `Environment=`
  lines, which replaces the Amazon Linux package's unit. AWS documents a
  systemd drop-in in `/etc/systemd/system/amazon-ssm-agent.service.d/` instead
  (TODO in `manifests/proxy.pp`).
* **The proxy settings are added again on every run and never removed.**
  `puppetlabs/inifile` reads the key of a line like
  `Environment="http_proxy=..."` as `Environment`, so it never finds the
  module's settings: every run with `proxy_url` appends the five `Environment=`
  lines again, and removing `proxy_url` leaves them in place. This happens with
  both the old inifile 2.2.0 and 6.5.0 (TODO in `manifests/proxy.pp`).
* **A changed proxy needs a service restart.** The proxy settings are applied
  before the service, but don't notify it.
* **Every run reports changes.** The package is downloaded to `/tmp` and removed
  again on every run (TODO in `manifests/init.pp`).
* **Amazon Linux 2023 needed its own Hiera data.** Without
  `data/RedHat/Amazon-2023.yaml`, the service provider fell back to `upstart` and
  the run failed in `amazon_ssm_agent::proxy`, which is why AEM OpenCloud
  pinned an unreleased commit. Rocky Linux 10 has the same data in
  `data/RedHat/Rocky-10.yaml`.

## Testing

Run the commands below in
[aem-platform-buildenv](https://github.com/shinesolutions/aem-platform-buildenv),
as CI does. Install the Ruby gems first:

    make deps

| Command | Runs |
| --- | --- |
| `make test` | Lint, syntax and `metadata.json` checks, unit specs and static checks |
| `make lint` | Puppet lint, syntax, `metadata.json` lint and the `make lint-extra` checks only |
| `make lint-extra` | The `make lint` checks that `make test` doesn't run: RuboCop, the misplaced files and UTF-8 checks, yamllint and markdownlint on every YAML and Markdown file, and the `.rtk.json` check |
| `make acceptance` | Acceptance tests with Beaker on every nodeset in `spec/acceptance/nodesets` (Amazon Linux 2023 and Rocky Linux 10), in Docker containers. They download the package from S3 |
| `make ci` | Everything CI runs, cheapest first: deps, `make lint-extra`, `make test`, acceptance tests and packaging |
| `make docs` | Generate the HTML reference in `docs/` |

## Versions History

See [CHANGELOG.md](CHANGELOG.md) for the changes in each version.

Releases are published to the [Puppet Forge](https://forge.puppet.com/modules/shinesolutions/amazon_ssm_agent)
and tagged `<version>` in git. Between releases, `metadata.json` holds the next
pre-release version, e.g. `1.1.1-pre.0`. To release:

1. Check that the `## Unreleased` entries in CHANGELOG.md on `main` describe
   everything in this release.
2. In GitHub Actions, run the **Release Major**, **Release Minor** or **Release
   Patch** workflow. It uses [RTK](https://github.com/cliffano/rtk), configured
   in `.rtk.json`, to set the release version in `metadata.json` and CHANGELOG.md,
   commit and tag it `<version>`, commit the next pre-release version, and push
   the commits and the tag. To do the same locally, run `make release` in
   aem-platform-buildenv, then push the commits and the tag.
3. The pushed tag triggers the **Publish Puppet Module** workflow, which builds
   the module and runs `make publish`: `make publish-check` checks the module is
   ready, then the package is pushed to the Forge. Publishing needs a Forge API
   key in `BLACKSMITH_FORGE_API_KEY`.
