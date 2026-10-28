# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased
### Added
- Added Amazon Linux 2023 and Rocky Linux 10 support, with systemd Hiera data for both
- Added unit and acceptance tests (Amazon Linux 2023 and Rocky Linux 10 nodesets) to GitHub CI
- Added Makefile targets for unit tests, acceptance tests, docs and publish checks
- Documented the known issues found on Amazon Linux 2023 in README.md

### Changed
- Upgraded to Ruby 4.0.7 and OpenVox 9 with Vox Pupuli tooling, replacing PDK
- Limited OS support to Amazon Linux 2023 and Rocky Linux 10, and the Puppet requirement to >= 7.0.0 < 10.0.0
- Changed the puppet/archive and puppetlabs/inifile dependencies to ranges, >= 6.0.0 < 10.0.0 and >= 6.0.0 < 7.0.0
- Simplify CI, publish and release workflows to not use action files anymore, running in aem-platform-buildenv 6.4.1
- Changed the parameter docs to puppet-strings tags
- Fall back to the GWDG mirror of yum.voxpupuli.org for the OpenVox 9 release package and repo in the acceptance nodesets, so an outage of yum.voxpupuli.org does not block CI

### Fixed
- Fixed the swapped service_enable and service_ensure parameter descriptions
- Fixed the syntax error in examples/proxy.pp
- Fixed README usage, which documented proxy_host and proxy_port parameters that don't exist

## 1.1.0 - 2022-07-12
### Changed
- Add 127.0.0.1 and localhost to default vales for no-proxy configuration

## 1.0.1 - 2021-10-05
### Added
- Add publish and release-* GitHub Actions

## 1.0.0 - 2021-02-14
### Added
- Add Puppet 7 to version requirement

### Changed
- Make service_ensure and service_enable configurable

## 0.12.0 - 2020-03-12
### Added
- Add support for Amazon Linux 2 arm instances

### Fixed
- Fix service provider name for CentOS7

## 0.11.0 - 2019-08-21
### Added
- Add example for proxy manifest

### Removed
- Removed systemd reload as it may interferes with other modules

## 0.10.0 - 2019-08-20
### Changed
- Seperated package installation & proxy configuration [#6]

## 0.9.4 - 2019-05-19
### Fixed
- Fix frozen string literal Rubocop violations

## 0.9.3 - 2018-10-29
### Added
- Introduce pdk as Puppet module build

### Changed
- Modify hierarchy to support Amazon Linux 2 config
- Change Puppet Archive version dependency to >= 1.3.0 <3.2.0
- Drop Puppet 4 support, add Puppet 6 support
- Drop ruby 2.1 and 2.2 support

## 0.9.2 - 2018-03-08
### Changed
- Temporarily drop upstart proxy config support
- Improve systemd proxy config to be not section-sequence dependent

## 0.9.1 - 2018-03-04
### Added
- Add https proxy support

## 0.9.0 - 2017-11-27
### Added
- Initial release
