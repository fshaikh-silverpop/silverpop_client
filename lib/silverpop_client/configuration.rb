#############################################################################################
#  Copyright 2013 Lumos Labs                                                                #
#                                                                                           #
#  This file is part of Lumos Labs Silverpop Client.                                        #
#                                                                                           #
#  Lumos Labs Silverpop Client is free software: you can redistribute it and/or modify      #
#  it under the terms of the GNU General Public License as published by                     #
#  the Free Software Foundation, either version 3 of the License, or                        #
#  (at your option) any later version.                                                      #
#                                                                                           #
#  Lumos Labs Silverpop Client is distributed in the hope that it will be useful,           #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of                           #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                            #
#  GNU General Public License for more details.                                             #
#                                                                                           #
#  You should have received a copy of the GNU General Public License                        #
#  along with Lumos Labs Silverpop Client.  If not, see <http://www.gnu.org/licenses/>.     #
#############################################################################################

require 'logger'

module SilverpopClient
  module Configuration
    VALID_CONFIG_KEYS =           [ :silverpop_api_url,
                                    :silverpop_api_port,
                                    :silverpop_api_path,
                                    :silverpop_transact_url,
                                    :silverpop_transact_port,
                                    :silverpop_transact_path,
                                    :silverpop_list_id,
                                    :silverpop_ftp_server,
                                    :silverpop_ftp_port,
                                    :silverpop_ftp_upload_path,
                                    :silverpop_ftp_download_path,
                                    :seconds_between_job_status_polling,
                                    :email_address_for_notifications,
                                    :logger ].freeze

    attr_accessor *VALID_CONFIG_KEYS

    DEFAULT_SILVERPOP_API_URL =       "api3.silverpop.com"
    DEFAULT_SILVERPOP_API_PORT =      80
    DEFAULT_SILVERPOP_API_PATH =      "/XMLAPI"

    DEFAULT_SILVERPOP_TRANSACT_URL =  "transact3.silverpop.com"
    DEFAULT_SILVERPOP_TRANSACT_PATH = "/XTMail"
    DEFAULT_SILVERPOP_TRANSACT_PORT = 80

    DEFAULT_SILVERPOP_FTP_SERVER =    "transfer3.silverpop.com"
    DEFAULT_SILVERPOP_FTP_PORT =      22
    DEFAULT_SILVERPOP_FTP_UPLOAD_PATH =      '/upload'
    DEFAULT_SILVERPOP_FTP_DOWNLOAD_PATH =      '/download'

    DEFAULT_SECONDS_BETWEEN_JOB_STATUS_POLLING = 60

    DEFAULT_EMAIL_ADDRESS_FOR_NOTIFICATIONS = nil

    DEFAULT_SILVERPOP_LIST_ID =       nil

    def configure
      yield self
    end

    def self.extended(base)
      base.reset
    end

    def reset
      self.silverpop_api_url =        DEFAULT_SILVERPOP_API_URL
      self.silverpop_api_port =       DEFAULT_SILVERPOP_API_PORT
      self.silverpop_api_path =       DEFAULT_SILVERPOP_API_PATH

      self.silverpop_ftp_server =     DEFAULT_SILVERPOP_FTP_SERVER
      self.silverpop_ftp_port =       DEFAULT_SILVERPOP_FTP_PORT
      self.silverpop_ftp_upload_path =       DEFAULT_SILVERPOP_FTP_UPLOAD_PATH
      self.silverpop_ftp_download_path =       DEFAULT_SILVERPOP_FTP_DOWNLOAD_PATH

      self.silverpop_transact_url =   DEFAULT_SILVERPOP_TRANSACT_URL
      self.silverpop_transact_path =  DEFAULT_SILVERPOP_TRANSACT_PATH
      self.silverpop_transact_port =  DEFAULT_SILVERPOP_TRANSACT_PORT

      self.seconds_between_job_status_polling = DEFAULT_SECONDS_BETWEEN_JOB_STATUS_POLLING

      self.email_address_for_notifications = DEFAULT_EMAIL_ADDRESS_FOR_NOTIFICATIONS

      self.silverpop_list_id =        DEFAULT_SILVERPOP_LIST_ID

      # If used from within a Rails application, you might want to set the logger to Rails.logger
      self.logger =                   Logger.new(STDERR)
      self.logger.level =             Logger::FATAL
    end
  end
end