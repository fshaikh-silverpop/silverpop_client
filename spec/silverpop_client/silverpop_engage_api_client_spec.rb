require 'spec_helper'

describe SilverpopClient::EngageApiClient do
  before :each do
    SilverpopClient.reset

    @test_username = "test"
    @test_password = "test"
    @client = SilverpopClient::EngageApiClient.new(@test_username, @test_password)
  end

  it 'should instantiate' do
    @client.should_not be nil
  end

  describe '.login' do
    it 'should not be logged in at first' do
      @client.logged_in?.should == false
    end

    it 'should be able to login and logout' do
      login_request_xml = SilverpopClient::XmlGenerators.xml_for_login("test", "test")
      logout_request_xml = SilverpopClient::XmlGenerators.xml_for_logout

      @client.should_receive(:post_to_silverpop_api).with(login_request_xml).once.and_return(successful_login_xml)
      @client.should_receive(:post_to_silverpop_engage_api).with(logout_request_xml).once.and_return(successful_logout_xml)

      result = @client.login
      @client.logged_in?.should == true

      @client.logout
      @client.logged_in?.should be_false
    end
  end

  describe '.request_sent_mailings_for_org' do

  end

  describe '.request_raw_recipient_report' do
    it 'should send the request correctly' do
      report_request_xml = SilverpopClient::XmlGenerators.xml_for_raw_recipient_data_export(Date.new(2012,11,1), Date.new(2012,11,2))

      @client.should_receive(:login).once.and_return("logged_in_string")
      @client.should_receive(:post_to_silverpop_engage_api).with(report_request_xml).once.and_return(successful_request_raw_recipient_export_response_xml)
      @client.should_receive(:logout)

      filename = @client.request_raw_recipient_data_export(Date.new(2012,11,1), Date.new(2012,11,2))
      filename.should == "15167_20041213100410_track.zip"
      @client.data_job_ids.should == ["72649"]
    end

    it 'should attempt the download' do
      download_args = [@test_username, @test_password, "some_filename.zip", "/data"]
      @client.should_receive(:request_raw_recipient_data_export).and_return("some_filename.zip")
      SilverpopClient::FtpRetrieval.should_receive(:download_report_from_silverpop_ftp).with(*download_args).and_return("/data/some_filename.zip")

      @client.request_and_retrieve_raw_recipient_data_export_report(Date.new(2012,5,1), Date.new(2012,5,1), "/data")
    end
  end
end