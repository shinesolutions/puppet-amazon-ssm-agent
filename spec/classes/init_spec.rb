require 'spec_helper'
describe 'amazon_ssm_agent' do
  context 'On RedHat with default values for all parameters' do
    let (:facts ) {
      {
        :os => {
          :architecture => "x86_64",
          :family => "RedHat",
          :hardware => "x86_64",
          :name => "RedHat",
          :release => {
            :full => "7.3",
            :major => "7",
            :minor => "3"
          },
          :selinux => {
            :enabled => false
          }
        }
      }
    }

    it { is_expected.to compile.with_all_deps }

    it { should contain_class('amazon_ssm_agent') }

    it { is_expected.to contain_package('amazon-ssm-agent') }
    it { is_expected.to contain_service('amazon-ssm-agent')
         .with_ensure('running')
         .with_enable(true)
    }
  end

  context 'On Amazon Linux with default values for all parameters' do
    let (:facts ) {
      {
        :os => {
            :architecture => "x86_64",
            :family => "RedHat",
            :hardware => "x86_64",
            :name => "Amazon",
            :release => {
              :full => "2017.03",
              :major => "2017",
              :minor => "03"
            },
            :selinux => {
              :enabled => false
            }
        }
      }
    }

    it { is_expected.to compile.with_all_deps }

    it { should contain_class('amazon_ssm_agent') }

    it { is_expected.to contain_package('amazon-ssm-agent') }
    it { is_expected.to contain_service('amazon-ssm-agent')
         .with_ensure('running')
         .with_enable(true)
    }
  end
end
