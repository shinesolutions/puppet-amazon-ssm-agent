# frozen_string_literal: true

require 'spec_helper'

describe 'amazon_ssm_agent::proxy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      # The ini_setting resources are ordered before this service, which amazon_ssm_agent declares
      let(:pre_condition) { "service { 'amazon-ssm-agent': }" }

      context 'with default values for all parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_ini_setting('Set no_proxy configuration with status absent') }
      end

      context 'with srv_provider => none' do
        let(:params) { { srv_provider: 'none' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_ini_setting_resource_count(0) }
      end

      context 'with srv_provider => upstart' do
        let(:params) { { srv_provider: 'upstart' } }

        it { is_expected.to compile.and_raise_error(%r{Module support for upstart service provider has been temporarily disabled}) }
      end
    end
  end
end
