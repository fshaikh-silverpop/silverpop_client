require "silverpop_client/version"
require "silverpop_client/configuration"
require "silverpop_client/client"
require "silverpop_client/engage_api_client"
require "silverpop_client/transact_client"
require "silverpop_client/ftp_retrieval"
require "silverpop_client/silverpop_date"
require "silverpop_client/xml_generators"

module SilverpopClient
  extend Configuration

  class Client
    include XmlGenerators
  end

  class EngageApiClient
    include FtpRetrieval
  end
end
