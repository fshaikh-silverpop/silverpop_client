require 'silverpop_client'

class TestLogger
  def self.info(str)
    puts "INFO: #{str}"
  end

  def self.error(str)
    puts "ERROR: #{str}}"
  end

  def self.debug(str)
    puts "DEBUG: #{str}"
  end

  def self.warn(str)
    puts "WARN: #{str}"
  end
end

def successful_login_xml
  xml = Builder::XmlMarkup.new
  xml.Envelope {
    xml.Body {
      xml.RESULT {
        xml.SUCCESS("TRUE")
        xml.SESSIONID("dc302149861088513512481")
        xml.SESSION_ENCODING(";jsessionid=dc302149861088513512481")
      }
    }
  }
end

def successful_logout_xml
  xml = Builder::XmlMarkup.new
  xml.Envelope {
    xml.Body {
      xml.RESULT {
        xml.SUCCESS("TRUE")
      }
    }
  }
end