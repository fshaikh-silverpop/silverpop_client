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

module SilverpopClient
  class SilverpopDate
    # Converts Silverpop's horrible format to a Date object, takes something like:
    #   November%2019,%202010
    def self.parse(spDate)
      Date.parse(spDate.gsub('%20', ' '), true) rescue nil
    end

    # Converts a Date object to Silverpop's horrible format, returns something like:
    #  November%2019,%202010
    def self.format(date)
      if date
        date.strftime("%B%%20%d,%%20%Y")
      else
        nil
      end
    end
  end
end
