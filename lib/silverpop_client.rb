require "silverpop_client/version"
require "silverpop_client/configuration"
require "silverpop_client/client"
require "silverpop_client/silverpop_date"
require "silverpop_client/xml_generators"

module SilverpopClient
  extend Configuration
  extend XmlGenerators
end