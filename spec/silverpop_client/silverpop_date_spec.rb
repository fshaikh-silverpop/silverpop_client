require 'spec_helper'

describe SilverpopClient::SilverpopDate, :feature_set => :emails do
  describe '.parse' do
    it 'parses a Silverpop-formatted date string to a Date object' do
      date = 'October%2013,%201974'
      SilverpopClient::SilverpopDate.parse(date).should == Date.parse('1974-10-13')
    end

    it 'parses any valid date string to a Date object' do
      date = '1974/10/13'
      SilverpopClient::SilverpopDate.parse(date).should == Date.parse(date)
    end

    it 'returns nil if the date string is invalid' do
      date = 'not a date'
      SilverpopClient::SilverpopDate.parse(date).should be_nil
    end
  end

  describe '.format' do
    it 'formats a date to the Silverpop format' do
      date = Date.parse('1974-10-13')
      SilverpopClient::SilverpopDate.format(date).should == 'October%2013,%201974'
    end
  end
end