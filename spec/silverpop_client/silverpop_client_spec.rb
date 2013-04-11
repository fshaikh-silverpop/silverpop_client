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

describe SilverpopClient::Client do
  before :each do
    SilverpopClient.reset
    SilverpopClient.silverpop_list_id = "123"

    @account_name = "transactional"
    @client = SilverpopClient::Client.new(:account_name => @account_name)

    @test_email = "somebody@domain.com"
  end

  it 'should have a version' do
    SilverpopClient::VERSION.should_not be_nil
  end

  it 'should instantiate' do
    @client.should_not be_nil
    @client.account_name.should == @account_name
  end

  describe '.update_contacts' do
    before :all do
      @update_xml = SilverpopClient::XmlGenerators.xml_for_add_recipient(sample_array_of_contact_hashes)
    end

    it 'should correctly build the XML' do
      @update_xml.should == update_sample_array_of_contact_hashes_xml
    end

    describe 'it should post the update contacts XML to silverpop' do
      it 'should return the correct array when all updates were successful' do
        @client.should_receive(:post_to_silverpop_api).with(update_sample_array_of_contact_hashes_xml).once.and_return(silverpop_add_recipient_response_xml(3, []))
        @client.update_contacts(sample_array_of_contact_hashes).should == []
      end

      it 'should return the correct array when one update failed' do
        @client.should_receive(:post_to_silverpop_api).with(update_sample_array_of_contact_hashes_xml).once.and_return(silverpop_add_recipient_response_xml(3, [0]))
        @client.update_contacts(sample_array_of_contact_hashes).should == [sample_array_of_contact_hashes[0]]
      end
    end
  end

  describe 'silverpop list management' do
    describe '.remove_contact' do
      it 'should post the correct xml to silverpop' do
        @client.should_receive(:post_to_silverpop_api).with(SilverpopClient::XmlGenerators.xml_for_remove_recipient(@test_email)).and_return(success_message)

        @client.remove_contact(@test_email).should be_true
      end

      it 'should return false when an error is returned' do
        @client.should_receive(:post_to_silverpop_api).with(SilverpopClient::XmlGenerators.xml_for_remove_recipient(@test_email)).and_return(failure_message)

        @client.remove_contact(@test_email).should be_false
      end
    end

    describe '.user_opted_out?' do
      it 'should figure out that the default xml is opted out' do
        @client.should_receive(:post_to_silverpop_api).with(SilverpopClient::XmlGenerators.xml_for_select_recipient_data(@test_email)).once.and_return(mailing_info_xml)
        @client.user_opted_out?(@test_email).should be_false
      end
    end

    describe '.get_recipient_data' do
      it 'should get the data' do
        @client.should_receive(:post_to_silverpop_api).with(SilverpopClient::XmlGenerators.xml_for_select_recipient_data(@test_email)).once.and_return(mailing_info_xml)
        @client.get_recipient_data(@test_email).should == mailing_info_xml
      end
    end

    describe '.email_address_exists?' do
      it 'should return true if user exists' do
        @client.should_receive(:post_to_silverpop_api).with(SilverpopClient::XmlGenerators.xml_for_select_recipient_data(@test_email)).once.and_return(mailing_info_xml)
        @client.email_address_exists?(@test_email).should be_true
      end

      it 'should return false if user is not found' do
        @client.should_receive(:post_to_silverpop_api).with(SilverpopClient::XmlGenerators.xml_for_select_recipient_data(@test_email)).once.and_return(failure_message)
        @client.email_address_exists?(@test_email).should be_false
      end
    end

    describe '.opt_out_contact' do
      it 'should send the xml to opt them out' do
        @client.should_receive(:post_to_silverpop_api).with(SilverpopClient::XmlGenerators.xml_for_opt_out_recipient(@test_email)).once.and_return(success_message)
        @client.opt_out_contact(@test_email)
      end
    end
  end
end
