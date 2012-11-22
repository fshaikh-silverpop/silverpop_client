require 'net/http'

module SilverpopClient
  class Client
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
  end
end