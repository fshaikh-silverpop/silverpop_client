require 'spec_helper'

describe SilverpopClient do
  before :all do
    SilverpopClient.logger = TestLogger
  end

  it 'should have a version' do
    SilverpopClient::VERSION.should_not be_nil
  end

  it 'should instantiate' do
    sc = SilverpopClient::Client.new("test", "test")
    sc.should_not be nil
  end

  describe '.login' do
    before :all do
      @client = SilverpopClient::Client.new("test", "test")
    end

    it 'should not be logged in at first' do
      @client.logged_in?.should == false
    end

    it 'should be able to login and out' do
      @login_request = @client.xml_for_login("test", "test")
      @logout_request = @client.xml_for_logout

      @client.should_receive(:post_to_silverpop_api).with(@login_request).once.and_return(successful_login_xml)
      @client.should_receive(:post_to_silverpop_engage_api).with(@logout_request).once.and_return(successful_logout_xml)

      result = @client.login
#      @client.result_successful?(result).should be_true
      @client.logged_in?.should == true

      @client.logout
      @client.logged_in?.should be_false
    end


    it 'should logout successfully' do
    end
  end
end
