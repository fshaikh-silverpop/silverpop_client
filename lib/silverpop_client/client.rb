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
    # Returns an array of contact hashes for all contacts that were NOT successfully updated

    def update_contacts(array_of_contact_hashes)
      response_xml = post_to_silverpop_api(XmlGenerators.xml_for_add_recipient(array_of_contact_hashes))

      not_successfully_updated = []

      error_indices = handle_response_errors(response_xml)
      array_of_contact_hashes.each_with_index do |hsh, i|
        not_successfully_updated << hsh if error_indices.include?(i)
      end

      if !not_successfully_updated.empty?
        SilverpopClient.logger.error("Error updating some contacts, XML for these contacts:")
        SilverpopClient.logger.error(XmlGenerators.xml_for_add_recipient(not_successfully_updated))
      end

      not_successfully_updated
    end
    alias_method :update_contact, :update_contacts

    ##
    # Removes +email+ from the silverpop list

    def remove_contact(email)
      result_successful?(post_to_silverpop_api(XmlGenerators.xml_for_remove_recipient(email)))
    end

    ##
    # Did +email+ user opt out of emails via silverpop?

    def user_opted_out?(email)
      Hpricot.XML(get_recipient_data(email)).search('optedout').andand.inner_text.present?
    rescue Exception
      false
    end

    ##
    # Pulls the property/value data silverpop has stored for +email+

    def get_recipient_data(email)
      post_to_silverpop_api(XmlGenerators.xml_for_select_recipient_data(email))
    end

    ##
    # Checks that a given user exists in silverpop's list

    def email_address_exists?(email)
      result_successful?(get_recipient_data(email)) rescue false
    end

    ##
    # Notify silverpop that +email+ has opted out

    def opt_out_contact(email)
      result_successful?(post_to_silverpop_api(XmlGenerators.xml_for_opt_out_recipient(email)))
    end

    private

    ##
    # Posts xml +data+ to silverpop's api

    def post_to_silverpop_api(data)
      SilverpopClient.logger.debug("Posting #{data} to #{SilverpopClient.silverpop_api_path}")
      post(SilverpopClient.silverpop_api_path, data)
    end

    ##
    # Look for generic SUCCESS property in +result+ xml from a silverpop query

    def result_successful?(result)
      Hpricot(result).search("/Envelope/Body/RESULT/SUCCESS").inner_text =~ /^TRUE$/i ? true : false
    end

    ##
    # Post +data+ to the +path+ specified on the configured Silverpop API server.
    #
    # Returns the XML response, or nil in case of exception.

    def post(path, data)
      raise 'Silverpop path not set!' if path.blank?
      @headers["Content-length"] = data.size.to_s
      SilverpopClient.logger.debug("Posting #{data} to #{path}")
      response = @http.start {|http| http.post(path, "xml=#{data}", @headers) }
      SilverpopClient.logger.debug("Response: #{response.pretty_inspect}")
      SilverpopClient.logger.debug("Response Body: #{response.body.pretty_inspect}")
      response.body
    end

    ##
    # Look for partial failure messages in the response +xml+ from Silverpop.
    # For example, sometimes with a call to AddRecipient, 9 out of 10 records will work but one will fail - this method returns the indices to the failed
    # values in the set passed to a function that works on sets

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