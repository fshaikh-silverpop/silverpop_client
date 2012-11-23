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

def sample_array_of_contact_hashes
  h1 = { "EMAIL" => "test@test.com", "User ID" => 12345, "Country" => "US", "City" => "New York", "State" => "NY"}
  h2 = { "EMAIL" => "test2@test.com", "User ID" => 12346, "Country" => "US", "City" => "Chicago", "State" => "IL"}
  h3 = { "EMAIL" => "test3@test.com", "User ID" => 12347, "Country" => "US", "City" => "San Francisco", "State" => "CA"}
  [h1, h2, h3]
end

def update_sample_array_of_contact_hashes_xml
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Envelope><Body><AddRecipient><CREATED_FROM>1</CREATED_FROM><UPDATE_IF_FOUND>true</UPDATE_IF_FOUND><COLUMN><NAME><![CDATA[EMAIL]]></NAME><VALUE><![CDATA[test@test.com]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[User ID]]></NAME><VALUE><![CDATA[12345]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[Country]]></NAME><VALUE><![CDATA[US]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[City]]></NAME><VALUE><![CDATA[New York]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[State]]></NAME><VALUE><![CDATA[NY]]></VALUE></COLUMN></AddRecipient><AddRecipient><CREATED_FROM>1</CREATED_FROM><UPDATE_IF_FOUND>true</UPDATE_IF_FOUND><COLUMN><NAME><![CDATA[EMAIL]]></NAME><VALUE><![CDATA[test2@test.com]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[User ID]]></NAME><VALUE><![CDATA[12346]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[Country]]></NAME><VALUE><![CDATA[US]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[City]]></NAME><VALUE><![CDATA[Chicago]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[State]]></NAME><VALUE><![CDATA[IL]]></VALUE></COLUMN></AddRecipient><AddRecipient><CREATED_FROM>1</CREATED_FROM><UPDATE_IF_FOUND>true</UPDATE_IF_FOUND><COLUMN><NAME><![CDATA[EMAIL]]></NAME><VALUE><![CDATA[test3@test.com]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[User ID]]></NAME><VALUE><![CDATA[12347]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[Country]]></NAME><VALUE><![CDATA[US]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[City]]></NAME><VALUE><![CDATA[San Francisco]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[State]]></NAME><VALUE><![CDATA[CA]]></VALUE></COLUMN></AddRecipient></Body></Envelope>"
end

def error_response_xml(i = 0)
  xml = Builder::XmlMarkup.new
  xml.RESULT {
    xml.SUCCESS("FALSE")
  }
  xml.Fault {
    xml.Request
    xml.FaultCode
    xml.FaultString("This is the error for the fake response with index #{i}.")
    xml.detail {
      xml.error {
        xml.errorid(108)
        xml.module
        xml.tag!(:class, "SP.ListManager")
        xml.tag!(:method)
      }
    }
  }
end

def silverpop_add_recipient_response_xml(results = 1, inject_failures_at_indices = [])
  base_recipient_id = 5710466905

  xml = "<Envelope>"
  xml << "<Body>"
  results.times do |i|
    if inject_failures_at_indices.include?(i)
      xml << error_response_xml(i)
    else
      xml << "<RESULT>"
      xml << "<SUCCESS>TRUE</SUCCESS>"
      xml << "<RecipientId>#{base_recipient_id+i}</RecipientId>"
      xml << "<ORGANIZATION_ID>2a8a9-12528112b1a-2d17c223308675814a3c362bb71726bf</ORGANIZATION_ID>"
      xml << "</RESULT>"
    end
  end
  xml << "</Body>"
  xml << "</Envelope>"
end