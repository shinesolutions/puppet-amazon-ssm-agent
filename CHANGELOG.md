# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

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
