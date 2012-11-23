module SilverpopClient
  class EngageApiClient < Client
    def initialize(username, password)
      super()

      @username = username
      @password = password
    end

    def logged_in?
      !!@silverpop_session_id
    end

    def login
      SilverpopClient.logger.info("Attempting to log in to silverpop with #{@username}...")
      SilverpopClient.logger.info("Sending #{xml_for_login(@username, @password)}")

      if logged_in?
        SilverpopClient.logger.info("Trying to login when already logged in...")
        return true
      end

      result = post_to_silverpop_api(xml_for_login(@username, @password))

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
      result = post_to_silverpop_engage_api(xml_for_logout)
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
    # Returns the filename

    def request_raw_recipient_data_export(start_date, end_date)
      filename = nil

      SilverpopClient.logger.info("Requesting raw recipient data export from silverpop from #{start_date} to #{end_date}...")

      begin
        login unless logged_in?
        result = post_to_silverpop_engage_api(xml_for_raw_recipient_data_export(start_date, end_date))
        if result_successful?(result)
          filename = Hpricot(result).search("/Envelope/Body/RESULT/MAILING/FILE_PATH").inner_text
          SilverpopClient.logger.info("Successfully requested raw recipient export from #{start_date} to #{end_date}; filename returned is #{filename}...")
        else
          raise "Error requesting silverpop report, result is #{result.pretty_inspect}..."
        end
      ensure
        logout
      end

      filename
    end

    private

    def post_to_silverpop_engage_api(data)
      raise "Must be logged in to post to the engage API!" unless logged_in?
      SilverpopClient.logger.debug("XML for silverpop request:\n#{data}")

      silverpop_path = @silverpop_session_encoding ? @silverpop_path + @silverpop_session_encoding : @silverpop_path
      post(silverpop_path, data)
    end
  end
end