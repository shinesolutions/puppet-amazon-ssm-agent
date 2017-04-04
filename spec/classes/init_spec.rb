require 'spec_helper'
describe 'amz_ssm_agent' do
  context 'with default values for all parameters' do
    it { should contain_class('amz_ssm_agent') }
  end
end
