require 'silverpop_client'

class TestLogger
  def self.info(str)
    puts "INFO: #{str}"
  end

  def self.error(str)
    puts "ERROR: #{str}}"
  end

  def self.debug(str)
    puts "DEBUG: #{str}"
  end

  def self.warn(str)
    puts "WARN: #{str}"
  end
end