require 'net/http'
require 'hpricot'

module SilverpopClient
  class Client

    attr_accessor :account_name

    ##
    # Instantiate the client object.  Options:
    #   :account_name - Will be used when writing files.  Useful if you are managing multiple silverpop_accounts.

    def initialize(options = {})
      @account_name = options[:account_name] ? options[:account_name] : ""
      @http = Net::HTTP.new(SilverpopClient.silverpop_api_url, SilverpopClient.silverpop_api_port)

      @headers = {
        "Host" => SilverpopClient.silverpop_api_url
      }
    end

    ##
    # Updates records in the Silverpop mailing list for hashes passed in +array_of_contact_hashes+
    #
    # Returns an array of contact hashes for all contacts that were successfully updated

    def update_contacts(array_of_contact_hashes)
      response_xml = post_to_silverpop_api(XmlGenerators.xml_for_add_recipient(array_of_contact_hashes))

      successfully_updated = []

      error_indices = handle_response_errors(response_xml)
      array_of_contact_hashes.each_with_index do |hsh, i|
        successfully_updated << hsh unless error_indices.include?(i)
      end

      successfully_updated
    end
    alias_method :update_contact, :update_contacts

    private

    def post_to_silverpop_api(data)
      post(SilverpopClient.silverpop_api_path, data)
    end

    def result_successful?(result)
      Hpricot(result).search("/Envelope/Body/RESULT/SUCCESS").inner_text =~ /^TRUE$/i ? true : false
    end

    def post(path, data)
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

    def handle_response_errors(xml, operation = 'addrecipient')
      error_indices = []
      return error_indices if !xml.is_a?(String)

      parsed_response = Hpricot(xml)
      unless parsed_response.search('faultstring').empty?
        faults = parsed_response.search('faultstring')
        parsed_response.search('result/success').each_with_index do |result,i|
           if result.inner_text != 'TRUE'
             error_indices << i
             error_string = faults.shift.inner_text
             request = Hpricot(xml).search("//#{operation}")[i]
             SilverpopClient.logger.error("-------\nError! #{error_string}\nRequest:\n#{request.to_s}\n-------\n")
           end
        end
      end
      error_indices
    end
  end
end