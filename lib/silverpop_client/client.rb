require 'net/http'

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
        Rails.logger.info("Successfully logged in to silverpop.")
        parsed_results = Hpricot(result)
        @silverpop_session_id = parsed_results.search("/Envelope/Body/Result/SESSIONID").inner_text
        @silverpop_session_encoding = parsed_results.search("/Envelope/Body/Result/SESSION_ENCODING").inner_text
        result
      else
        Rails.logger.error("Failed login in to silverpop, result was #{result.pretty_inspect}...")
        raise "Login failed with result #{result.pretty_inspect}"
      end
    end
  end
end