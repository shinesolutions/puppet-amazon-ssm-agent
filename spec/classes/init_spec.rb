# frozen_string_literal: true

require 'spec_helper'

describe 'amazon_ssm_agent' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:architecture) { 'amd64' }

      context 'with default values for all parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('amazon_ssm_agent') }
        it { is_expected.to contain_class('amazon_ssm_agent::proxy').with_srv_provider('systemd') }

        it {
          is_expected.to contain_archive('/tmp/amazon-ssm-agent.rpm')
            .with_source("https://amazon-ssm-us-east-1.s3.amazonaws.com/latest/linux_#{architecture}/amazon-ssm-agent.rpm")
            .that_comes_before('Package[amazon-ssm-agent]')
        }

        it {
          is_expected.to contain_package('amazon-ssm-agent')
            .with_ensure('latest')
            .with_provider('rpm')
            .with_source('/tmp/amazon-ssm-agent.rpm')
        }

        it {
          is_expected.to contain_service('amazon-ssm-agent')
            .with_ensure('running')
            .with_enable(true)
            .with_provider('systemd')
        }

        it { is_expected.to contain_file('/tmp/amazon-ssm-agent.rpm').with_ensure('absent').that_requires('Package[amazon-ssm-agent]') }

        ['http_proxy', 'https_proxy', 'HTTP_PROXY', 'HTTPS_PROXY'].each do |proxy_env_var|
          it { is_expected.to contain_ini_setting("Set proxy configuration #{proxy_env_var} with status absent").with_ensure('absent') }
        end
        it { is_expected.to contain_ini_setting('Set no_proxy configuration with status absent').with_ensure('absent') }
      end

      context 'with region => ap-southeast-2' do
        let(:params) { { region: 'ap-southeast-2' } }

        it {
          is_expected.to contain_archive('/tmp/amazon-ssm-agent.rpm')
            .with_source("https://amazon-ssm-ap-southeast-2.s3.amazonaws.com/latest/linux_#{architecture}/amazon-ssm-agent.rpm")
        }
      end

      context 'with proxy_url => http://someproxy:3128' do
        let(:params) { { proxy_url: 'http://someproxy:3128' } }

        ['http_proxy', 'https_proxy', 'HTTP_PROXY', 'HTTPS_PROXY'].each do |proxy_env_var|
          it {
            is_expected.to contain_ini_setting("Set proxy configuration #{proxy_env_var} with status present")
              .with_ensure('present')
              .with_path('/etc/systemd/system/amazon-ssm-agent.service')
              .with_section('Service')
              .with_setting("Environment=\"#{proxy_env_var}")
              .with_value('http://someproxy:3128"')
              .with_key_val_separator('=')
              .that_comes_before('Service[amazon-ssm-agent]')
          }
        end

        it {
          is_expected.to contain_ini_setting('Set no_proxy configuration with status present')
            .with_ensure('present')
            .with_path('/etc/systemd/system/amazon-ssm-agent.service')
            .with_setting('Environment="no_proxy')
            .with_value('169.254.169.254,127.0.0.1,localhost"')
        }
      end

      context 'with service_ensure => false' do
        let(:params) { { service_ensure: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('amazon-ssm-agent') }
        it { is_expected.not_to contain_class('amazon_ssm_agent::proxy') }
        it { is_expected.not_to contain_service('amazon-ssm-agent') }
      end

      context 'with service_ensure => stopped and service_enable => false' do
        let(:params) { { service_ensure: 'stopped', service_enable: false } }

        it { is_expected.to contain_service('amazon-ssm-agent').with_ensure('stopped').with_enable(false) }
      end

      # facterdb has no aarch64 facts for Amazon Linux 2023, so override the architecture fact
      context 'on aarch64' do
        let(:facts) { os_facts.merge(os: os_facts[:os].merge('architecture' => 'aarch64')) }

        it {
          is_expected.to contain_archive('/tmp/amazon-ssm-agent.rpm')
            .with_source('https://amazon-ssm-us-east-1.s3.amazonaws.com/latest/linux_arm64/amazon-ssm-agent.rpm')
        }
      end

      context 'on an unsupported architecture' do
        let(:facts) { os_facts.merge(os: os_facts[:os].merge('architecture' => 's390x')) }

        it { is_expected.to compile.and_raise_error(%r{Module not supported on s390x architecture}) }
      end
    end
  end
end
