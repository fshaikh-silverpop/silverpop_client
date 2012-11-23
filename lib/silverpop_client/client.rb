require 'net/http'
require 'hpricot'

module SilverpopClient
  class Client

    def initialize
      @http = Net::HTTP.new(SilverpopClient.silverpop_url, SilverpopClient.silverpop_port)

      @headers = {
        "Host" => SilverpopClient.silverpop_url
      }
    end

    private

    def post_to_silverpop_api(data)
      post(@silverpop_path, data)
    end

    def result_successful?(result)
      Hpricot(result).search("/Envelope/Body/RESULT/SUCCESS").inner_text =~ /^TRUE$/i ? true : false
    end

    def post(path, data)
      return if self.class.disabled?("didn't post #{data} to #{path}")

      begin
        raise 'Silverpop path not set!' if path.blank?
        @headers["Content-length"] = data.size.to_s
        SilverpopClient.logger.debug("Posting #{data} to #{path}")
        response = @http.start {|http| http.post(path, "xml=#{data}", @headers) }
        response.body
      rescue Exception => ex
        SilverpopClient.logger.error("post_to_silverpop_api exception!\n#{ex}")
        nil
      end
    end
  end
end