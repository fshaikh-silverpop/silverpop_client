require 'net/sftp'

module SilverpopClient
  class FtpRetrieval

    ##
    # Attempts to download +report_filename+ from the configured silverpop_ftp_path in the SilverpopClient gem
    #
    # Returns the path to the downloaded file

    def self.download_report_from_silverpop_ftp(silverpop_login, silverpop_password, report_filename, output_path)
      remote_file = File.join(SilverpopClient.silverpop_ftp_path, report_filename)
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
        SilverpopClient.logger.errpr('Message: %s' % e.message)
      end

      local_filename
    end
  end
end