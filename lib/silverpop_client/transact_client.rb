module SilverpopClient
  class TransactClient < Client
    def initialize
      @http = Net::HTTP.new(SilverpopClient.silverpop_transact_url, SilverpopClient.silverpop_transact_port)

      @headers = {
        "Host" => SilverpopClient.silverpop_transact_url
      }
    end
  end
end