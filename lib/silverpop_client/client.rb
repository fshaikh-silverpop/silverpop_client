module SilverpopClient
  class Client
    def initialize
#      @http = Net::HTTP.new(@silverpop_url, @silverpop_port)
      @headers = {
        "Host" => @silverpop_url
      }
      @silverpop_session_id = nil
      @silverpop_session_encoding = nil

      @error_reporting = :stderr
    end
  end
end