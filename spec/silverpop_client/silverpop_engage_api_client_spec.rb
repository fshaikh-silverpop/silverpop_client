#############################################################################################
#  Copyright 2013 Lumos Labs                                                                #
#                                                                                           #
#  This file is part of Lumos Labs Silverpop Client.                                        #
#                                                                                           #
#  Lumos Labs Silverpop Client is free software: you can redistribute it and/or modify      #
#  it under the terms of the GNU General Public License as published by                     #
#  the Free Software Foundation, either version 3 of the License, or                        #
#  (at your option) any later version.                                                      #
#                                                                                           #
#  Lumos Labs Silverpop Client is distributed in the hope that it will be useful,           #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of                           #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                            #
#  GNU General Public License for more details.                                             #
#                                                                                           #
#  You should have received a copy of the GNU General Public License                        #
#  along with Lumos Labs Silverpop Client.  If not, see <http://www.gnu.org/licenses/>.     #
#############################################################################################

require 'spec_helper'

describe SilverpopClient::EngageApiClient do
  before :each do
    SilverpopClient.reset

    @test_username = "test"
    @test_password = "test"
    @client = SilverpopClient::EngageApiClient.new(@test_username, @test_password)
    @login_request_xml = SilverpopClient::XmlGenerators.xml_for_login(@test_username, @test_password)

    @output_path = "/data"
  end

  it 'should instantiate' do
    @client.should_not be nil
  end

  describe '.login' do
    it 'should not be logged in at first' do
      @client.logged_in?.should == false
    end

    it 'should be able to login and logout' do
      login_request_xml = SilverpopClient::XmlGenerators.xml_for_login(@test_username, @test_password)
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
    before :all do

      @start_date = Date.new(2011, 1, 1)
      @end_date =  Date.new(2011, 1, 15)

      @sent_mailing_request_xml = SilverpopClient::XmlGenerators.xml_for_get_sent_mailings_for_org(@start_date, @end_date)
    end

    it 'should submit the request' do
      @client.should_receive(:post_to_silverpop_api).with(@login_request_xml).once.and_return(successful_login_xml)
      @client.should_receive(:post_to_silverpop_engage_api).with(@sent_mailing_request_xml).once.and_return(silverpop_mailing_data_response_xml)
      @client.should_receive(:generate_sent_mailings_csv).with(silverpop_mailing_data_response_xml)
      @client.should_receive(:logout).once.and_return(successful_logout_xml)

      @client.request_sent_mailings_for_org(@start_date, @end_date)
    end

    it 'should generate csv data from the output' do
      @client.send(:generate_sent_mailings_csv, silverpop_mailing_data_response_xml).should == silverpop_mailing_data_csv
    end

    it 'should write to the correct file' do
      @client.should_receive(:post_to_silverpop_api).with(@login_request_xml).once.and_return(successful_login_xml)
      @client.should_receive(:post_to_silverpop_engage_api).with(@sent_mailing_request_xml).once.and_return(silverpop_mailing_data_response_xml)
      @client.should_receive(:generate_sent_mailings_csv).with(silverpop_mailing_data_response_xml).and_return(silverpop_mailing_data_csv)
      @client.should_receive(:logout).once.and_return(successful_logout_xml)

      file = mock('file')
      FileUtils.should_receive(:mkdir_p).with(@output_path)
      File.should_receive(:open).with(File.join(@output_path, "silverpop_sent_mailings__20110101_to_20110115.csv"), "w").and_yield(file)
      file.should_receive(:write).with(silverpop_mailing_data_csv.join("\n"))

      @client.download_sent_mailings_for_org(@start_date, @end_date, @output_path)
    end
  end

  describe '.request_raw_recipient_report' do
    it 'should build the correct XML request' do
      SilverpopClient.email_address_for_notifications = "test@test.com"
      SilverpopClient::XmlGenerators.xml_for_raw_recipient_data_export(Date.new(2012,11,1), Date.new(2012,11,2)).should == successful_request_raw_recipient_export_xml
    end

    it 'should send the request correctly' do
      report_request_xml = SilverpopClient::XmlGenerators.xml_for_raw_recipient_data_export(Date.new(2012,11,1), Date.new(2012,11,2))

      @client.should_receive(:login).once
      @client.should_receive(:post_to_silverpop_engage_api).with(report_request_xml).once.and_return(successful_request_raw_recipient_export_response_xml)
      @client.should_receive(:logout)

      filename = @client.request_raw_recipient_data_export(Date.new(2012,11,1), Date.new(2012,11,2))
      filename.should == "15167_20041213100410_track.zip"
      @client.data_job_ids.should == ["72649"]
    end

    it 'should attempt the download' do
      download_args = [@test_username, @test_password, "some_filename.zip", @output_path]
      @client.should_receive(:request_raw_recipient_data_export).and_return("some_filename.zip")
      @client.should_receive(:wait_for_job_completion).and_return(SilverpopClient::EngageApiClient::JOB_STATUS_COMPLETE)
      FileUtils.should_receive(:mkdir_p).with(@output_path)
      SilverpopClient::FtpRetrieval.should_receive(:download_report_from_silverpop_ftp).with(*download_args).and_return("/data/some_filename.zip")

      @client.request_and_retrieve_raw_recipient_data_export_report(Date.new(2012,5,1), Date.new(2012,5,1), "/data")
    end
  end

  describe '.get_job_status' do
    before :all do
      @job_id = 1234
    end

    it 'should submit the XML and parse out the status for one job' do
      @client.should_receive(:login).once
      @client.should_receive(:post_to_silverpop_engage_api).with(SilverpopClient::XmlGenerators.xml_for_get_job_status(@job_id)).once.and_return(job_status_response_xml(SilverpopClient::EngageApiClient::JOB_STATUS_WAITING))
      @client.should_receive(:logout)

      @client.get_job_status(@job_id).should == SilverpopClient::EngageApiClient::JOB_STATUS_WAITING
    end

    it 'should pull all the statuses for everything in the data_job_ids array' do
      @client.data_job_ids = [@job_id, 5678]

      @client.should_receive(:login).once
      @client.should_receive(:post_to_silverpop_engage_api).with(SilverpopClient::XmlGenerators.xml_for_get_job_status(@client.data_job_ids[0])).once.and_return(job_status_response_xml(SilverpopClient::EngageApiClient::JOB_STATUS_WAITING))
      @client.should_receive(:logout)

      @client.should_receive(:login).once
      @client.should_receive(:post_to_silverpop_engage_api).with(SilverpopClient::XmlGenerators.xml_for_get_job_status(@client.data_job_ids[1])).once.and_return(job_status_response_xml(SilverpopClient::EngageApiClient::JOB_STATUS_COMPLETE))
      @client.should_receive(:logout)

      @client.get_job_statuses.should == [SilverpopClient::EngageApiClient::JOB_STATUS_WAITING, SilverpopClient::EngageApiClient::JOB_STATUS_COMPLETE]
    end

    describe '.wait_for_job_completion' do
      before :each do
        SilverpopClient.seconds_between_job_status_polling = 0
      end

      it 'should poll until it gets COMPLETE' do
        @client.should_receive(:get_job_status).once.and_return(SilverpopClient::EngageApiClient::JOB_STATUS_WAITING)
        @client.should_receive(:get_job_status).exactly(2).times.and_return(SilverpopClient::EngageApiClient::JOB_STATUS_RUNNING)
        @client.should_receive(:get_job_status).once.and_return(SilverpopClient::EngageApiClient::JOB_STATUS_COMPLETE)

        @client.send(:wait_for_job_completion, @job_id).should == SilverpopClient::EngageApiClient::JOB_STATUS_COMPLETE
      end

      it 'should handle CANCELED status' do
        @client.should_receive(:get_job_status).once.and_return(SilverpopClient::EngageApiClient::JOB_STATUS_WAITING)
        @client.should_receive(:get_job_status).exactly(2).times.and_return(SilverpopClient::EngageApiClient::JOB_STATUS_RUNNING)
        @client.should_receive(:get_job_status).once.and_return(SilverpopClient::EngageApiClient::JOB_STATUS_CANCELED)

        @client.send(:wait_for_job_completion, @job_id).should == SilverpopClient::EngageApiClient::JOB_STATUS_CANCELED
      end

      it 'should handle ERROR status with an exception' do
        @client.should_receive(:get_job_status).once.and_return(SilverpopClient::EngageApiClient::JOB_STATUS_WAITING)
        @client.should_receive(:get_job_status).exactly(2).times.and_return(SilverpopClient::EngageApiClient::JOB_STATUS_RUNNING)
        @client.should_receive(:get_job_status).once.and_return(SilverpopClient::EngageApiClient::JOB_STATUS_ERROR)

        expect {@client.send(:wait_for_job_completion, @job_id)}.to raise_error
      end
    end
  end
end