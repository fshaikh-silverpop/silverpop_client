require 'spec_helper'

describe SilverpopClient::EngageApiClient do
  before :all do
    SilverpopClient.reset
  end

  it 'should instantiate' do
    sc = SilverpopClient::EngageApiClient.new("test", "test")
    sc.should_not be nil
  end

  describe '.login' do
    before :all do
      @client = SilverpopClient::EngageApiClient.new("test", "test")
    end

    it 'should not be logged in at first' do
      @client.logged_in?.should == false
    end

    it 'should be able to login and logout' do
      login_request_xml = @client.xml_for_login("test", "test")
      logout_request_xml = @client.xml_for_logout

      @client.should_receive(:post_to_silverpop_api).with(login_request_xml).once.and_return(successful_login_xml)
      @client.should_receive(:post_to_silverpop_engage_api).with(logout_request_xml).once.and_return(successful_logout_xml)

      result = @client.login
      @client.logged_in?.should == true

      @client.logout
      @client.logged_in?.should be_false
    end
  end

  describe '.request_raw_recipient_report' do
    before :all do
      @client = SilverpopClient::EngageApiClient.new("test", "test")
    end

    it 'should send the request correctly' do
      report_request_xml = @client.xml_for_raw_recipient_data_export(Date.new(2012,11,1), Date.new(2012,11,2))

      @client.should_receive(:login).once.and_return("logged_in_string")
      @client.should_receive(:post_to_silverpop_engage_api).with(report_request_xml).once.and_return(successful_request_raw_recipient_export_response_xml)
      @client.should_receive(:logout)

      filename = @client.request_raw_recipient_data_export(Date.new(2012,11,1), Date.new(2012,11,2))
      filename.should == "15167_20041213100410_track.zip"
      @client.data_job_ids.should == ["72649"]
    end
  end
end