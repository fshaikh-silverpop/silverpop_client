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

require 'net/sftp'

module SilverpopClient
  class FtpTransport

    ##
    # Attempts to download +report_filename+ from the configured silverpop_ftp_path in the SilverpopClient gem
    #
    # Returns the path to the downloaded file

    def self.download_report_from_silverpop_ftp(silverpop_login, silverpop_password, report_filename, output_path)
      remote_file = File.join(SilverpopClient.silverpop_ftp_download_path, report_filename)
      local_filename = File.join(output_path, "#{report_filename}")

      begin
        Net::SSH.start(SilverpopClient.silverpop_ftp_server, silverpop_login, :password => silverpop_password) do |ssh|
          ssh.sftp.connect do |sftp|
            SilverpopClient.logger.info("Attempting download of #{remote_file} to #{local_filename}")
            sftp.download!(remote_file, local_filename)
          end
        end
      rescue Exception => e
        SilverpopClient.logger.error('SFTP exception: %s' % e)
        SilverpopClient.logger.error('Source: %s' % e.backtrace)
        SilverpopClient.logger.error('Message: %s' % e.message)
      end

      local_filename
    end

    ##
    # Attempts to upload +filename+ from the configured silverpop_ftp_upload_path in the SilverpopClient gem
    #
    # Returns the path to the uploaded file

    def self.upload_file_to_silverpop_ftp(silverpop_login, silverpop_password, local_filepath, filename)
      remote_file = File.join(SilverpopClient.silverpop_ftp_upload_path, filename)
      local_filename = File.join(local_filepath, "#{filename}")

      begin
        Net::SSH.start(SilverpopClient.silverpop_ftp_server, silverpop_login, :password => silverpop_password) do |ssh|
          ssh.sftp.connect do |sftp|
            SilverpopClient.logger.info("Attempting upload of #{local_filename} to #{remote_file}")
            sftp.upload!(local_filename, remote_file)
          end
        end
      rescue Exception => e
        SilverpopClient.logger.error('SFTP exception: %s' % e)
        SilverpopClient.logger.error('Source: %s' % e.backtrace)
        SilverpopClient.logger.error('Message: %s' % e.message)
      end

      remote_file
    end

  end
end
