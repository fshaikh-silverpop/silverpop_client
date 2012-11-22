require 'spec_helper'

describe '.configure' do
  SilverpopClient::Configuration::VALID_CONFIG_KEYS.each do |key|
    it "should set the #{key}" do
      SilverpopClient.configure do |config|
        config.send("#{key}=", key)
        SilverpopClient.send(key).should == key
      end
    end
  end
end
