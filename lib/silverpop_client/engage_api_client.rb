module SilverpopClient
  class EngageApiClient < Client

    attr_accessor :data_job_ids

    def initialize(username, password, options = {})
      super(options)

      @username = username
      @password = password

      @silverpop_session_id = nil
      @silverpop_session_encoding = nil

      @data_job_ids = []
    end

    def logged_in?
      !!@silverpop_session_id
    end

    def login
      SilverpopClient.logger.info("Attempting to log in to silverpop with #{@username}...")
      SilverpopClient.logger.info("Sending #{XmlGenerators.xml_for_login(@username, @password)}")

      if logged_in?
        SilverpopClient.logger.info("Trying to login when already logged in...")
        return true
      end

      result = post_to_silverpop_api(XmlGenerators.xml_for_login(@username, @password))

      if result_successful?(result)
        SilverpopClient.logger.info("Successfully logged in to silverpop.")
        parsed_results = Hpricot(result)
        @silverpop_session_id = parsed_results.search("/Envelope/Body/Result/SESSIONID").inner_text
        @silverpop_session_encoding = parsed_results.search("/Envelope/Body/Result/SESSION_ENCODING").inner_text
        result
      else
        SilverpopClient.logger.info("Failed login in to silverpop, result was #{result.pretty_inspect}...")
        raise "Login failed with result #{result.pretty_inspect}"
      end
    end

    def logout
      SilverpopClient.logger.info("Attempting to log out from silverpop...")
      result = post_to_silverpop_engage_api(XmlGenerators.xml_for_logout)
      if result_successful?(result)
        SilverpopClient.logger.info("Successfully logged out.")
        @silverpop_session_id = nil
        @silverpop_session_encoding = nil
        true
      else
        SilverpopClient.logger.info("Failed to logout from silverpop! Error: #{result.pretty_inspect}")
        false
      end
    end

    ##
    # Submits a raw recipient report request to silverpop from +start_date+ to +end_date+
    #
    # Returns the filename silverpop will write the report out to on their FTP server
    # Populates the job id in data_job_ids

    def request_raw_recipient_data_export(start_date, end_date)
      filename = nil

      SilverpopClient.logger.info("Requesting raw recipient data export from silverpop from #{start_date} to #{end_date}...")

      begin
        login unless logged_in?

        result = post_to_silverpop_engage_api(XmlGenerators.xml_for_raw_recipient_data_export(start_date, end_date))
        if result_successful?(result)
          filename = Hpricot(result).search("/Envelope/Body/RESULT/MAILING/FILE_PATH").inner_text
          data_job_ids << Hpricot(result).search("/Envelope/Body/RESULT/MAILING/JOB_ID").inner_text

          SilverpopClient.logger.info("Successfully requested raw recipient export from #{start_date} to #{end_date}; filename returned is #{filename}, job_id is #{data_job_ids.last}...")
        else
          raise "Error requesting silverpop report, result is #{result.pretty_inspect}..."
        end
      ensure
        logout
      end

      filename
    end

    ##
    # Creates the request for the data export from +start_date+ to +end_date+ and writes the output to +output_path+
    #
    # Returns the full path of the downloaded file

    def request_and_retrieve_raw_recipient_data_export_report(start_date, end_date, output_path)
      filename = request_raw_recipient_data_export(start_date, end_date)
      FtpRetrieval.download_report_from_silverpop_ftp(@username, @password, filename, output_path)
    end

    ##
    # Request a list of sent mailing from +start_date+ to +end_date+ and write them to +output_path+

    def request_sent_mailings_for_org(start_date, end_date, output_path)
      login unless logged_in?

      SilverpopClient.logger.info("Requesting list of sent mailings from silverpop...")

      result = nil
      begin
        result = post_to_silverpop_engage_api(xml_for_get_sent_mailings_for_org(start_date, end_date))
        if result && result_successful?(result)
          Rails.logger.info("Silverpop request was successful, result is #{result.pretty_inspect}...")
        else
          if result.nil?
            Rails.logger.error("Error requesting silverpop report, empty response...")
          else
            Rails.logger.error("Error requesting silverpop report, result is #{result.pretty_inspect}...")
          end
          raise "Problem with silverpop response"
        end
        result
      ensure
        logout
      end

      dump_sent_mailings_xml_to_csv(result, File.join(output_path, "silverpop_#{@account_name}_#{start_date.strftime('%Y%m%d')}_to_#{end_date.strftime('%Y%m%d')}.csv"))
    end

    private

    ##
    # Posts xml +data+ to the engage API

    def post_to_silverpop_engage_api(data)
      raise "Must be logged in to post to the engage API!" unless logged_in?
      SilverpopClient.logger.debug("XML for silverpop request:\n#{data}")

      silverpop_path = @silverpop_session_encoding ? SilverpopClient.silverpop_api_path + @silverpop_session_encoding : SilverpopClient.silverpop_api_path
      post(silverpop_path, data)
    end

    ##
    # Parses out a csv from +response_xml+ and writes it to +output_filename
    #
    # Returns an array of comma separated strings with a header row at index 0

    def generate_sent_mailings_csv(response_xml, output_filename)
      doc = REXML::Document.new(response_xml)

      csv_doc = ["mailing_id,report_id,scheduled_ts,mailing_name,list_name,list_id,parent_list_id,user_name,sent_ts,num_sent,subject,visibility"]

      doc.elements.each("Envelope/Body/RESULT/Mailing") do |mailing|
        row = []

        time = mailing.elements["ScheduledTS"].text.to_time.strftime('%a %b %-d %H:%M:%S %Z %Y').sub('GMT', 'UTC')

        row << (mailing.elements["MailingId"] ? mailing.elements["MailingId"].text : nil)
        row << (mailing.elements["ReportId"] ? mailing.elements["ReportId"].text : nil)
        row << (mailing.elements["ScheduledTS"] ? time : nil)
        row << (mailing.elements["MailingName"] ? mailing.elements["MailingName"].text : nil)
        row << (mailing.elements["ListName"] ? mailing.elements["ListName"].text : nil)

        row << (mailing.elements["ListId"] ? mailing.elements["ListId"].text : nil)
        row << (mailing.elements["ParentListId"] ? mailing.elements["ParentListId"].text : nil)
        row << (mailing.elements["UserName"] ? mailing.elements["UserName"].text : nil)
        row << (mailing.elements["SentTS"] ? mailing.elements["SentTS"].text : nil)
        row << (mailing.elements["NumSent"] ? mailing.elements["NumSent"].text : nil)
        row << (mailing.elements["Subject"] ? mailing.elements["Subject"].text.gsub(/,|\"/, "") : nil)
        row << (mailing.elements["Visibility"] ? mailing.elements["Visibility"].text : nil)

        row = row.collect {|col| col.nil? ? "\\N" : col}

        csv_doc << row.join(",")
      end

      File.open("#{output_filename}_#{$$}.csv", "w") {|f| f.write(csv_doc.join("\n"))}
    end
  end
end