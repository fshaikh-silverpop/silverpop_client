require 'spec_helper'

describe SilverpopClient do
  it 'should have a version' do
    SilverpopClient::VERSION.should_not be_nil
  end

  it 'should instantiate' do
    sc = SilverpopClient::Client.new("test", "test")
    sc.should_not be nil
  end
end