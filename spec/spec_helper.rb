require 'silverpop_client'

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