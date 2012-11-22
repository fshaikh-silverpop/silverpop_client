module SilverpopClient
  module Configuration
    VALID_CONNECTION_KEYS =       [:username, :password].freeze
    VALID_OPTIONS_KEYS =          [:silverpop_url, :silverpop_port, :silverpop_path, :silverpop_list_id, :silverpop_ftp_server, :silverpop_ftp_port].freeze
    VALID_CONFIG_KEYS =           VALID_CONNECTION_KEYS + VALID_OPTIONS_KEYS

    attr_accessor *VALID_CONFIG_KEYS

    DEFAULT_SILVERPOP_USERNAME =  "test"
    DEFAULT_SILVERPOP_PASSWORD =  "test"

    DEFAULT_SILVERPOP_URL =       "transfer3.silverpop.com"
    DEFAULT_SILVERPOP_PORT =      80
    DEFAULT_SILVERPOP_PATH =      "/XMLAPI"

    DEFAULT_SILVERPOP_LIST_ID =   nil
    DEFAULT_SILVERPOP_FTP_SERVER = "transfer3.silverpop.com"
    DEFAULT_SILVERPOP_FTP_PORT =  22

    def configure
      yield self
    end

    def self.extended(base)
      base.reset
    end

    def reset
      self.username = DEFAULT_SILVERPOP_USERNAME
      self.password = DEFAULT_SILVERPOP_PASSWORD

      self.silverpop_url = DEFAULT_SILVERPOP_URL
      self.silverpop_path = DEFAULT_SILVERPOP_PATH
      self.silverpop_port = DEFAULT_SILVERPOP_PORT

      self.silverpop_list_id = DEFAULT_SILVERPOP_LIST_ID
      self.silverpop_ftp_server = DEFAULT_SILVERPOP_FTP_SERVER
      self.silverpop_ftp_port = DEFAULT_SILVERPOP_FTP_PORT
    end
  end
end

