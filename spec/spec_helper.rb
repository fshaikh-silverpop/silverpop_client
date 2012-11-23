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

def successful_request_raw_recipient_export_xml
  xml = Builder::XmlMarkup.new
  xml_base {|xml|
    xml.RawRecipientDataExport {
      xml.EVENT_DATE_START("11/01/2012")
      xml.EVENT_DATE_END("11/02/2012")
      xml.EXPORT_FORMAT(0)
      xml.MOVE_TO_FTP
      xml.EMAIL("test")
      xml.ALL_EVENT_TYPES
    }
  }
end

def successful_request_raw_recipient_export_response_xml
  "<Envelope><Body><RESULT><SUCCESS>TRUE</SUCCESS><MAILING><JOB_ID>72649</JOB_ID><FILE_PATH>15167_20041213100410_track.zip</FILE_PATH></MAILING></RESULT></Body></Envelope>"
end