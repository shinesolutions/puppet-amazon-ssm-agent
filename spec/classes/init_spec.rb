require 'spec_helper'
describe 'amazon_ssm_agent' do
  context 'On RedHat with default values for all parameters' do
    let (:facts ) {
      {
        :os => {
          :architecture => "x86_64",
          :family => "RedHat",
          :hardware => "x86_64",
          :name => "Darwin",
          :release => {
            :full => "16.5.0",
            :major => "16",
            :minor => "5"
          }
        }
      }
    }

    it { should contain_class('amazon_ssm_agent') }
  end
end
