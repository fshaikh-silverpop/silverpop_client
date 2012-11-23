require "silverpop_client/version"
require "silverpop_client/configuration"
require "silverpop_client/client"
require "silverpop_client/engage_api_client"
require "silverpop_client/silverpop_date"
require "silverpop_client/xml_generators"
require "silverpop_client/logger"

module SilverpopClient
  extend Configuration

  class Client
    include XmlGenerators
  end
end
