require 'net/http'
require 'hpricot'

module SilverpopClient
  class Client
#    include XmlGenerators

    def initialize(username, password)
      @username = username
      @password = password

      @http = Net::HTTP.new(SilverpopClient.silverpop_url, SilverpopClient.silverpop_port)

      @headers = {
        "Host" => SilverpopClient.silverpop_url
      }

      @silverpop_session_id = nil
      @silverpop_session_encoding = nil

      @error_reporting = :stderr
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

    def post_to_silverpop_engage_api(data)
      raise "Not logged in!" unless logged_in?
      SilverpopClient.logger.debug("XML for silverpop request:\n#{data}")

      silverpop_path = @silverpop_session_encoding ? @silverpop_path + @silverpop_session_encoding : @silverpop_path
      post(silverpop_path, data)
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

      start_date = start_date.to_date
      end_date = end_date.to_date
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
        filename
      ensure
        logout
      end
      result
    end

    private

    def result_successful?(result)
      Hpricot(result).search("/Envelope/Body/RESULT/SUCCESS").inner_text =~ /^TRUE$/i ? true : false
    end

    def post(path, data)
      return if self.class.disabled?("didn't post #{data} to #{path}")

      begin
        raise 'Silverpop path not set!' if path.blank?
        @headers["Content-length"] = data.size.to_s
        Rails.logger.info("Posting #{data} to #{path}")
        response = @http.start {|http| http.post(path, "xml=#{data}", @headers) }
        response.body
      rescue Exception => ex
        Rails.logger.error("post_to_silverpop_api exception!\n#{ex}")
        error("-------\nError! exception: #{ex}\n")
        nil
      end
    end
  end
end