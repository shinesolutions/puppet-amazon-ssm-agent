# frozen_string_literal: true

require 'spec_helper_acceptance'

# Not checked for idempotency: every run downloads the package again and then
# removes it (see the TODO in manifests/init.pp), so every run reports changes.
describe 'amazon_ssm_agent class' do
  # Amazon Linux 2023 AMIs ship the agent from the Amazon Linux repo, with its
  # unit in /usr/lib/systemd/system; the module replaces it with the S3 package.
  context 'with the Amazon Linux 2023 agent package already installed' do
    # Checked at run time, once beaker has set up the host
    before(:each) { skip('Rocky Linux has no Amazon Linux agent package') unless default['platform'].start_with?('amazon') }

    it 'installs the Amazon Linux package' do
      install_package(default, 'amazon-ssm-agent')
      expect(check_for_package(default, 'amazon-ssm-agent')).to be true
    end

    it 'applies with no errors' do
      apply_manifest('include amazon_ssm_agent', catch_failures: true)
    end

    it 'replaces it with the package from S3' do
      expect(shell('rpm -q --qf "%{RELEASE}" amazon-ssm-agent').stdout).not_to match(%r{amzn2023})
    end

    describe file('/etc/systemd/system/amazon-ssm-agent.service') do
      it { is_expected.to be_file }
    end
  end

  context 'with default parameters' do
    it 'applies again with no errors' do
      apply_manifest('include amazon_ssm_agent', catch_failures: true)
    end

    describe package('amazon-ssm-agent') do
      it { is_expected.to be_installed }
    end

    describe file('/tmp/amazon-ssm-agent.rpm') do
      it { is_expected.not_to exist }
    end

    describe service('amazon-ssm-agent') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe file('/etc/systemd/system/amazon-ssm-agent.service') do
      its(:content) { is_expected.not_to match(%r{proxy}) }
    end
  end

  context 'with proxy_url => http://someproxy:3128' do
    it 'applies with no errors' do
      apply_manifest("class { 'amazon_ssm_agent': proxy_url => 'http://someproxy:3128' }", catch_failures: true)
    end

    describe file('/etc/systemd/system/amazon-ssm-agent.service') do
      ['http_proxy', 'https_proxy', 'HTTP_PROXY', 'HTTPS_PROXY'].each do |proxy_env_var|
        its(:content) { is_expected.to match(%r{^Environment="#{proxy_env_var}=http://someproxy:3128"$}) }
      end
      its(:content) { is_expected.to match(%r{^Environment="no_proxy=169.254.169.254,127.0.0.1,localhost"$}) }
    end

    describe service('amazon-ssm-agent') do
      it { is_expected.to be_running }
    end
  end

  context 'with proxy_url removed' do
    it 'applies with no errors' do
      apply_manifest('include amazon_ssm_agent', catch_failures: true)
    end

    it 'removes the proxy settings' do
      pending('ini_setting reads the key as Environment, so it never finds the proxy settings to remove (TODO in manifests/proxy.pp)')
      expect(file('/etc/systemd/system/amazon-ssm-agent.service').content).not_to match(%r{proxy})
    end
  end
end
