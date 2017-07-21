require File.dirname(__FILE__) + '/nagios_plugin.rb'
require 'time'

class LogAgeChecker < NagiosPlugin
  def initialize( filename, stream = STDOUT )
    @filename = filename
    super( stream )
  end

  def check( warn, crit )
    begin
      age = Time.now.to_i - File.mtime( @filename ).to_i
    rescue Errno::ENOENT
      return critical( "File not found: #{@filename}" )
    end
    if age > crit
      return critical( "#{@filename} is too old (age #{age}s, max #{crit}s)" )
    elsif age > warn
      return warning( "#{@filename} is too old (age #{age}s, max #{warn}s)" )
    else
      return ok( "#{age}s" )
    end
  end
end

