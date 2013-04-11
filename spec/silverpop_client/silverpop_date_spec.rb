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

describe SilverpopClient::SilverpopDate do
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