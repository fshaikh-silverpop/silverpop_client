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
      SilverpopClient.logger.info("Attempting to log in to silverpop with #{@username}...") if SilverpopClient.logger
      SilverpopClient.logger.info("Sending #{xml_for_login(@username, @password)}") if SilverpopClient.logger

      if logged_in?
        SilverpopClient.logger.info("Trying to login when already logged in...") if SilverpopClient.logger
        return true
      end

      result = post_to_silverpop_api(xml_for_login(@username, @password))

      if result_successful?(result)
        SilverpopClient.logger.info("Successfully logged in to silverpop.") if SilverpopClient.logger
        parsed_results = Hpricot(result)
        @silverpop_session_id = parsed_results.search("/Envelope/Body/Result/SESSIONID").inner_text
        @silverpop_session_encoding = parsed_results.search("/Envelope/Body/Result/SESSION_ENCODING").inner_text
        result
      else
        SilverpopClient.logger.info("Failed login in to silverpop, result was #{result.pretty_inspect}...")  if SilverpopClient.logger
        raise "Login failed with result #{result.pretty_inspect}"
      end
    end

    def logout
      SilverpopClient.logger.info("Attempting to log out from silverpop...") if SilverpopClient.logger
      result = post_to_silverpop_engage_api(xml_for_logout) if SilverpopClient.logger
      if result_successful?(result)
        SilverpopClient.logger.info("Successfully logged out.") if SilverpopClient.logger
        @silverpop_session_id = nil
        @silverpop_session_encoding = nil
        true
      else
        SilverpopClient.logger.info("Failed to logout from silverpop! Error: #{result.pretty_inspect}")  if SilverpopClient.logger
        false
      end
    end


    private

    def result_successful?(result)
      Hpricot(result).search("/Envelope/Body/RESULT/SUCCESS").inner_text =~ /^TRUE$/i ? true : false
    end
  end
end