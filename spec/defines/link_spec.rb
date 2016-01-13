require 'spec_helper'

describe 'puppet_redbox::link' do
  shared_context "stubbed params" do
    let (:title) {'redbox/storage'}
  end

  let :default_params do
    {
      :target => title,
      :target_parent => '/opt',
      :relocation => '/mnt/data',
      :owner => 'redbox'
    }
  end

  context "Given default parameters" do
    include_context "stubbed params"
    let :params do
      default_params
    end
    it do
      should contain_exec("mv redbox/storage")
    end
  end
end