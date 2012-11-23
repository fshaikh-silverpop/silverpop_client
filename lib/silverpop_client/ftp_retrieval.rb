require 'net/sftp'

module SilverpopClient
  class FtpRetrieval

    ##
    # Attempts to download +report_filename+ from the configured silverpop_ftp_path in the SilverpopClient gem
    # Returns the path to the downloaded file

    def self.download_report_from_silverpop_ftp(silverpop_login, silverpop_password, report_filename, output_path)
      remote_file = SilverpopClient.silverpop_ftp_path + "/" + report_filename
      local_filename = File.join(output_path, "#{report_filename}")

      retries = 10
      begin
        Net::SSH.start(SilverpopClient.silverpop_ftp_server, silverpop_login, :password => silverpop_password) do |ssh|
          ssh.sftp.connect do |sftp|
            begin
              SilverpopClient.logger.info("Attempting download of #{remote_file} to #{local_filename}")
              sftp.download!(remote_file, local_filename)
            rescue RuntimeError => e
              SilverpopClient.logger.info('Connection Error: %s' % e)
              SilverpopClient.logger.info('Source: %s' % e.backtrace)
              SilverpopClient.logger.info('Message: %s' % e.message)

              if e.message =~ /no such file/
                SilverpopClient.logger.info("File #{report_filename} doesn't exist (yet), sleeping 9 minutes and retrying.")
                sleep(540)
                retry
              end
            end
          end
        end
      rescue Errno::ECONNRESET => e
        SilverpopClient.logger.info("ECONNRESET thrown by silverpop; #{retries} tries left.")
        retries -= 1
        if retries > 0
          retry
        else
          raise "Out of retries for silverpop download."
        end
      end

      local_filename
    end
  end
end