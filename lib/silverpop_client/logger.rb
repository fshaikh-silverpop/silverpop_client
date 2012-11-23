module SilverpopClient
  class BasicLogger
    def info(str)
      puts "INFO: #{str}"
    end

    def error(str)
      puts "ERROR: #{str}}"
    end

    def debug(str)
      puts "DEBUG: #{str}"
    end

    def warn(str)
      puts "WARN: #{str}"
    end
  end
end