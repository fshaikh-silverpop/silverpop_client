require 'spec_helper'

describe SilverpopClient do
  before :all do
    SilverpopClient.reset
    SilverpopClient.silverpop_list_id = "123"
  end

  it 'should have a version' do
    SilverpopClient::VERSION.should_not be_nil
  end

  it 'should instantiate' do
    sc = SilverpopClient::Client.new
    sc.should_not be nil
  end

  describe '.update_contacts' do
    before :all do
      @client = SilverpopClient::Client.new
      @update_xml = SilverpopClient::XmlGenerators.xml_for_add_recipient(sample_array_of_contact_hashes)
    end

    it 'should correctly build the XML' do
      @update_xml.should == update_sample_array_of_contact_hashes_xml
    end

    describe 'it should post the update contacts XML to silverpop' do
      it 'should return the correct array when all updates were successful' do
        @client.should_receive(:post_to_silverpop_api).with(update_sample_array_of_contact_hashes_xml).once.and_return(silverpop_add_recipient_response_xml(3, []))
        @client.update_contacts(sample_array_of_contact_hashes).should == sample_array_of_contact_hashes
      end

      it 'should return the correct array when one update failed' do
        @client.should_receive(:post_to_silverpop_api).with(update_sample_array_of_contact_hashes_xml).once.and_return(silverpop_add_recipient_response_xml(3, [0]))
        @client.update_contacts(sample_array_of_contact_hashes).should == sample_array_of_contact_hashes[1..2]
      end
    end
  end
end
