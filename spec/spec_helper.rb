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
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Envelope><Body><AddRecipient><LIST_ID>123</LIST_ID><CREATED_FROM>1</CREATED_FROM><UPDATE_IF_FOUND>true</UPDATE_IF_FOUND><COLUMN><NAME><![CDATA[EMAIL]]></NAME><VALUE><![CDATA[test@test.com]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[User ID]]></NAME><VALUE><![CDATA[12345]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[Country]]></NAME><VALUE><![CDATA[US]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[City]]></NAME><VALUE><![CDATA[New York]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[State]]></NAME><VALUE><![CDATA[NY]]></VALUE></COLUMN></AddRecipient><AddRecipient><LIST_ID>123</LIST_ID><CREATED_FROM>1</CREATED_FROM><UPDATE_IF_FOUND>true</UPDATE_IF_FOUND><COLUMN><NAME><![CDATA[EMAIL]]></NAME><VALUE><![CDATA[test2@test.com]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[User ID]]></NAME><VALUE><![CDATA[12346]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[Country]]></NAME><VALUE><![CDATA[US]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[City]]></NAME><VALUE><![CDATA[Chicago]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[State]]></NAME><VALUE><![CDATA[IL]]></VALUE></COLUMN></AddRecipient><AddRecipient><LIST_ID>123</LIST_ID><CREATED_FROM>1</CREATED_FROM><UPDATE_IF_FOUND>true</UPDATE_IF_FOUND><COLUMN><NAME><![CDATA[EMAIL]]></NAME><VALUE><![CDATA[test3@test.com]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[User ID]]></NAME><VALUE><![CDATA[12347]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[Country]]></NAME><VALUE><![CDATA[US]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[City]]></NAME><VALUE><![CDATA[San Francisco]]></VALUE></COLUMN><COLUMN><NAME><![CDATA[State]]></NAME><VALUE><![CDATA[CA]]></VALUE></COLUMN></AddRecipient></Body></Envelope>"
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

def silverpop_mailing_data_response_xml
  "<Envelope>
  <Body>
  <RESULT>
  <SUCCESS>TRUE</SUCCESS>
  <Mailing>
  <MailingId>4727357</MailingId>
  <ReportId>171702887</ReportId>
  <ScheduledTS>2011-01-24 06:00:00.0</ScheduledTS>
  <MailingName><![CDATA[Sale_New Years_35 Perc_StartFresh B_2011.01.24_Low 5]]></MailingName>
  <ListName><![CDATA[Sale_Low_5]]></ListName>
  <ListId>1152641</ListId>
  <ParentListId>906300</ParentListId>
  <UserName>Julie Nguyen</UserName>
  <SentTS/>
  <NumSent>0</NumSent>
  <Subject><![CDATA[Your Future Is Brighter With Lumosity.]]></Subject>
  <Visibility>Shared</Visibility>
  </Mailing>
  <Mailing>
  <MailingId>4827180</MailingId>
  <ReportId>177637189</ReportId>
  <ScheduledTS>2011-05-15 09:00:00.0</ScheduledTS>
  <MailingName><![CDATA[Brain Trainer Start Trial Drip_Day 03_01234_2011.04.21_5 Day Trial]]></MailingName>
  <ListName><![CDATA[Brain Trainer Start Trial Drip 01234]]></ListName>
  <ListId>959321</ListId>
  <ParentListId>906300</ParentListId>
  <UserName>Julie Nguyen</UserName>
  <SentTS>2011-05-15 09:10:58.0</SentTS>
  <NumSent>1</NumSent>
  <Subject><![CDATA[Your Gift from Lumosity]]></Subject>
  <Visibility>Shared</Visibility>
  </Mailing>
  </RESULT>
  </Body>
  </Envelope>"
end

def silverpop_mailing_data_csv
  [
    "mailing_id,report_id,scheduled_ts,mailing_name,list_name,list_id,parent_list_id,user_name,sent_ts,num_sent,subject,visibility",
    "4727357,171702887,Mon Jan 24 06:00:00 UTC 2011,Sale_New Years_35 Perc_StartFresh B_2011.01.24_Low 5,Sale_Low_5,1152641,906300,Julie Nguyen,\\N,0,Your Future Is Brighter With Lumosity.,Shared",
    "4827180,177637189,Sun May 15 09:00:00 UTC 2011,Brain Trainer Start Trial Drip_Day 03_01234_2011.04.21_5 Day Trial,Brain Trainer Start Trial Drip 01234,959321,906300,Julie Nguyen,2011-05-15 09:10:58.0,1,Your Gift from Lumosity,Shared"
  ]
end

def success_message
  "<Envelope><Body><RESULT><SUCCESS>TRUE</SUCCESS></RESULT></BODY></ENVELOPE>"
end

def failure_message
  "<Envelope><Body><RESULT><SUCCESS>FALSE</SUCCESS></RESULT></BODY></ENVELOPE>"
end

def mailing_info_xml
  "<Envelope> <Body>
  <RESULT> <SUCCESS>TRUE</SUCCESS> <EMAIL>somebody@domain.com</EMAIL> <Email>somebody@domain.com</Email> <RecipientId>33439394</RecipientId> <EmailType>0</EmailType> <LastModified>6/25/04 3:29 PM</LastModified> <CreatedFrom>1</CreatedFrom> <OptedIn>6/25/04 3:29 PM</OptedIn> <OptedOut/> <COLUMNS>
  <COLUMN> <NAME>Fname</NAME> <VALUE>Somebody</VALUE>
  </COLUMN> <COLUMN>
  <NAME>Lname</NAME>
  <VALUE>Special</VALUE> </COLUMN>
  </COLUMNS> </RESULT>
  </Body> </Envelope>"
end

def job_status_response_xml(status)
  "<Envelope> <Body>
  <RESULT>
  <SUCCESS>TRUE</SUCCESS>
  <JOB_ID>789052</JOB_ID> <JOB_STATUS>#{status}</JOB_STATUS>
  <JOB_DESCRIPTION>Creating new contact source, Master Database</JOB_DESCRIPTION>
  <PARAMETERS>
  <PARAMETER> <NAME>NOT_ALLOWED</NAME>
  <VALUE>0</VALUE> </PARAMETER>
  <PARAMETER> <NAME>LIST_ID</NAME>
  <VALUE>116347</VALUE> </PARAMETER>
  <PARAMETER> <NAME>RESULTS_FILE_NAME</NAME> <VALUE>1241474.res</VALUE>
  </PARAMETER> <PARAMETER>
  <NAME>SQL_ADDED</NAME>
  <VALUE>65535</VALUE> </PARAMETER>
  <PARAMETER> <NAME>DUPLICATES</NAME>
  <VALUE>0</VALUE> </PARAMETER>
  <PARAMETER> <NAME>TOTAL_ROWS</NAME>
  <VALUE>65535</VALUE> </PARAMETER>
  <PARAMETER> <NAME>ERROR_FILE_NAME</NAME>
  <VALUE>1241474.err</VALUE> </PARAMETER>
  <PARAMETER> <NAME>LIST_NAME</NAME>
  <VALUE>Big List</VALUE> </PARAMETER>
  <PARAMETER> <NAME>BAD_ADDRESSES</NAME>
  <VALUE>0</VALUE> </PARAMETER>
  <PARAMETER> <NAME>SQL_UPDATED</NAME>
  <VALUE>0</VALUE> </PARAMETER>
  <PARAMETER> <NAME>BAD_RECORDS</NAME>
  <VALUE>0</VALUE> </PARAMETER>
  <PARAMETER> <NAME>TOTAL_VALID</NAME>
  <VALUE>65535</VALUE> </PARAMETER>
  </PARAMETERS>
  </RESULT>
  </Body> </Envelope>"
end