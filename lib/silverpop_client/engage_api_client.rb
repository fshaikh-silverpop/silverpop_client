require 'rexml/document'

module SilverpopClient
  class EngageApiClient < Client

    JOB_STATUS_WAITING =  "WAITING"
    JOB_STATUS_RUNNING =  "RUNNING"
    JOB_STATUS_CANCELED = "CANCELED"
    JOB_STATUS_ERROR =    "ERROR"
    JOB_STATUS_COMPLETE = "COMPLETE"
    JOB_STATUS_UNKNOWN =  "UNKNOWN"

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

    ##
    # Logs in with the credentials passed at client instantiation time.  All requests to post_to_silverpop_engage_api will be prepended
    # with the session encoding returned from a successful request.
    #
    # All data requests will actually log the client in and out, so there is usually no need to call this directly if you are using
    # the provided API methods.

    def login
      if logged_in?
        SilverpopClient.logger.info("Trying to login when already logged in...")
        return true
      else
        SilverpopClient.logger.info("Attempting to log in to silverpop with #{@username}...")
      end

      result = post_to_silverpop_api(XmlGenerators.xml_for_login(@username, @password))

      if result_successful?(result)
        SilverpopClient.logger.info("Successfully logged in to silverpop.")
        parsed_results = Hpricot(result)
        @silverpop_session_id = parsed_results.search("/Envelope/Body/Result/SESSIONID").inner_text
        @silverpop_session_encoding = parsed_results.search("/Envelope/Body/Result/SESSION_ENCODING").inner_text
        result
      else
        SilverpopClient.logger.error("Failed login in to silverpop, result was #{result.pretty_inspect}...")
        raise "Login failed with result #{result.pretty_inspect}"
      end
    end

    ##
    # Logs out of the silverpop API; sets the session_encoding and session_id back to nil

    def logout
      SilverpopClient.logger.info("Attempting to log out from silverpop...")

      result = post_to_silverpop_engage_api(XmlGenerators.xml_for_logout)
      if result_successful?(result)
        SilverpopClient.logger.info("Successfully logged out.")
        @silverpop_session_id = nil
        @silverpop_session_encoding = nil
        true
      else
        SilverpopClient.logger.error("Failed to logout from silverpop! Error: #{result.pretty_inspect}")
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
      wait_for_job_completion(@data_job_ids.last)
      FtpRetrieval.download_report_from_silverpop_ftp(@username, @password, filename, output_path)
    end

    ##
    # Request a list of sent mailing from +start_date+ to +end_date+ and write them to +output_path+

    def request_sent_mailings_for_org(start_date, end_date)
      SilverpopClient.logger.info("Requesting list of sent mailings from silverpop...")

      login unless logged_in?

      result = nil
      begin
        result = post_to_silverpop_engage_api(XmlGenerators.xml_for_get_sent_mailings_for_org(start_date, end_date))
        if result && result_successful?(result)
          SilverpopClient.logger.debug("Silverpop request was successful, result is #{result.pretty_inspect}...")
        else
          if result.nil?
            raise("Error requesting silverpop report, empty response...")
          else
            raise("Error requesting silverpop report, result is #{result.pretty_inspect}...")
          end
        end
        result
      ensure
        logout
      end

      generate_sent_mailings_csv(result)
    end

    ##
    # Handles requesting the sent mailing response xml from +start_date+ to +end_date+ and writing to +output_path+

    def download_sent_mailings_for_org(start_date, end_date, output_path)
      output_filename = File.join(output_path, "silverpop_sent_mailings_#{@account_name ? @account_name + "_" : ""}#{start_date.strftime('%Y%m%d')}_to_#{end_date.strftime('%Y%m%d')}.csv")

      csv_doc = request_sent_mailings_for_org(start_date, end_date)
      File.open(output_filename, "w") {|f| f.write(csv_doc.join("\n"))}
    end

    ##
    # Gets the statuses for all jobs whose ids are in the data_job_ids array
    #
    # Returns an array of statuses the same size as data_job_ids

    def get_job_statuses
      @data_job_ids.map {|job_id| get_job_status(job_id)}
    end

    ##
    # Gets the status for the job with id +job_id+

    def get_job_status(job_id)
      login unless logged_in?

      begin
        result = post_to_silverpop_engage_api(XmlGenerators.xml_for_get_job_status(job_id))
        if(result_successful?(result))
          Hpricot(result).search("/Envelope/Body/RESULT/JOB_STATUS").inner_text
        else
          SilverpopClient.logger.error("Failed to retrieve status for job #{job_id}")
          JOB_STATUS_UNKNOWN
        end
      ensure
        logout
      end
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
    # Parses out a csv from +response_xml+
    #
    # Returns an array of CSV strings.

    def generate_sent_mailings_csv(response_xml)
      doc = REXML::Document.new(response_xml)

      csv_doc = ["mailing_id,report_id,scheduled_ts,mailing_name,list_name,list_id,parent_list_id,user_name,sent_ts,num_sent,subject,visibility"]

      doc.elements.each("Envelope/Body/RESULT/Mailing") do |mailing|
        row = []

        time = DateTime.parse(mailing.elements["ScheduledTS"].text).to_time.utc.strftime('%a %b %-d %H:%M:%S %Z %Y').sub('GMT', 'UTC')

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

      csv_doc
    end

    ##
    # Waits for a job to return the status COMPLETE for +job_id+
    #
    # Raises an error if it gets job status ERROR; returns CANCELED if it gets job status CANCELED

    def wait_for_job_completion(job_id)
      while (job_status = get_job_status(job_id)) !~ /#{JOB_STATUS_ERROR}|#{JOB_STATUS_COMPLETE}|#{JOB_STATUS_CANCELED}/
        SilverpopClient.logger.info("Job ID #{job_id} had status #{job_status}; sleeping #{SilverpopClient.seconds_between_job_status_polling} seconds")
        sleep(SilverpopClient.seconds_between_job_status_polling)
      end

      return job_status if job_status == JOB_STATUS_COMPLETE

      if job_status == JOB_STATUS_ERROR or job_status == JOB_STATUS_UNKNOWN
        SilverpopClient.logger.error("Error reported by job status for job #{job_id}")
        raise "Error reported by job status for job #{job_id}"
      elsif job_status == JOB_STATUS_CANCELED
        SilverpopClient.logger.warn("Job #{job_id} canceled.")
        return job_status
      end
    end
  end
end