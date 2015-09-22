require 'spec_helper'

# Ported from https://github.com/chef/omnibus-chef/blob/master/jenkins/verify-chefdk.sh
describe 'chef-verify' do
  describe command('sudo chef verify --unit') do
    its(:exit_status) { should eq 0 }
  end
end
