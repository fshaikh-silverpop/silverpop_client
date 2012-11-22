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
        date.send(:strftime, "%B%%20%d,%%20%Y")
      else
        nil
      end
    end
  end
end
